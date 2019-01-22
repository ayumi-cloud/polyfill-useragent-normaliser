"use strict";

const fs = require("fs");
const path = require("path");
const data = JSON.parse(
  fs.readFileSync(path.join(__dirname, "../data.json"), "utf8")
);
const version = JSON.parse(
  fs.readFileSync(path.join(__dirname, "../package.json"))
).version.replace(/\./g, "_");
const ua_parser_vcl = fs.readFileSync(
  require.resolve("@financial-times/useragent_parser/lib/ua_parser.vcl"),
  "utf8"
);

let file = `${ua_parser_vcl}

sub normalise_user_agent_${version} {
  if (!req.http.User-Agent) {
    set req.http.Normalized-User-Agent = "other/0.0.0";
  } elsif (req.http.User-Agent ~ {"${data.isNormalized}"}) {
    set req.http.normalized_user_agent_family = std.tolower(re.group.1);
    set req.http.normalized_user_agent_major_version = re.group.2;
    set req.http.normalized_user_agent_minor_version = re.group.3;
    set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
  } else {
`;
// 1. Add the normalisations
for (const { reason, regex } of data.normalisations) {
  let s = "";
  s += `\n\t\t# ${reason}`;
  s += `\n\t\tset req.http.User-Agent = regsub(req.http.User-Agent, {"${regex}"}, "");\n`;
  file += s;
}

// 2. Do the useragent parsing into family/major.minor.patch
file += `
        call useragent_parser;

        # Clone the original values for later modification. This helps when debugging as it let's us see what the useragent_parser function returned.
        set req.http.normalized_user_agent_family = req.http.useragent_parser_family;
        set req.http.normalized_user_agent_major_version = req.http.useragent_parser_major;
        set req.http.normalized_user_agent_minor_version = req.http.useragent_parser_minor;
        set req.http.normalized_user_agent_patch_version = req.http.useragent_parser_patch;
`;

// For improved CDN cache performance, remove the patch version.  There are few cases in which a patch release drops the requirement for a polyfill, but if so, the polyfill can simply be served unnecessarily to the patch versions that contain the fix, and we can stop targeting at the next minor release.
file += `\n\t\tset req.http.normalized_user_agent_patch_version = "0";\n`;

// 3. Aliases
file += `\n\t\tset req.http.normalized_user_agent_family = std.tolower(req.http.useragent_parser_family);\n`;
for (const [family, alias] of Object.entries(data.aliases)) {
  if (typeof alias === "string") {
    file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}") {
            set req.http.normalized_user_agent_family = "${alias}";
		}`;
  } else if (Array.isArray(alias)) {
    file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}") {
            set req.http.normalized_user_agent_family = "${alias[0]}";
            set req.http.normalized_user_agent_major_version = "${alias[1]}";
        }`;
  } else if (typeof alias === "object") {
    file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}") {`;
    for (const [range, replacement] of Object.entries(alias)) {
      const [major, minor] = range.split(".");
      if (minor !== undefined) {
        file += `\n\t\t\tif (req.http.normalized_user_agent_major_version == "${major}" && req.http.normalized_user_agent_minor_version == "${minor}") {`;
      } else {
        file += `\n\t\t\tif (req.http.normalized_user_agent_major_version == "${major}") {`;
      }
      file += `
                set req.http.normalized_user_agent_family = "${replacement[0]}";
                set req.http.normalized_user_agent_major_version = "${
                  replacement[1]
                }";
            }`;
    }
    file += `\n\t\t}`;
  }
}

// 4. Check if browser and version are in the baseline supported browser versions
for (const [family, range] of Object.entries(data.baselineVersions)) {
  if (range === "*") {
    file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}") {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }`;
  } else {
    if (Number.isInteger(Number(range))) {
      file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}" && std.atoi(req.http.normalized_user_agent_major_version) >= ${range}) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }`;
    } else {
      const [major, minor] = range.split(".");
      file += `\n\t\tif (req.http.normalized_user_agent_family == "${family}" && std.atoi(req.http.normalized_user_agent_major_version) >= ${major} && std.atoi(req.http.normalized_user_agent_minor_version) >= ${minor}) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }`;
    }
  }
}
file += `\n\t\tif (!req.http.Normalized-User-Agent) {
            set req.http.normalized_user_agent_family = "other";
            set req.http.normalized_user_agent_major_version = "0";
            set req.http.normalized_user_agent_minor_version = "0";
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }`;
file += `
    }
}`;

fs.writeFileSync(
  path.join(__dirname, "../lib/normalise-user-agent.vcl"),
  file,
  "utf8"
);
