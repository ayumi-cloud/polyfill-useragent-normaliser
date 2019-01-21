
sub normalise_user_agent_1.0.0 {
  if (!req.http.User-Agent) {
    set req.http.Normalized-User-Agent = "other/0.0.0";
  } elsif (req.http.User-Agent ~ {"/^(\w+)/(\d+)(?:\.(\d+)(?:\.(\d+))?)?$/"}) {
    set req.http.normalized_user_agent_family = std.tolower(re.group.1);
    set req.http.normalized_user_agent_major_version = re.group.2;
    set req.http.normalized_user_agent_minor_version = re.group.3;
    set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
  } else {

		# Chrome and Opera on iOS uses a UIWebView of the underlying platform to render content. By stripping the CriOS or OPiOS strings, the useragent parser will alias the user agent to ios_saf for the UIWebView, which is closer to the actual renderer
		set req.http.User-Agent = regsub(req.http.User-Agent, {"/((CriOS|OPiOS)/(\d+)\.(\d+)\.(\d+)\.(\d+)|(FxiOS/(\d+)\.(\d+)))/"}, "");

		# Vivaldi browser is recognised by UA module but is actually identical to Chrome, so the best way to get accurate targeting is to remove the vivaldi token from the UA
		set req.http.User-Agent = regsub(req.http.User-Agent, {"/ vivaldi/[\d\.]+\d+/i"}, "");

		# Facebook in-app browser `[FBAN/.....]` or `[FB_IAB/.....]` (see https://github.com/Financial-Times/polyfill-service/issues/990)
		set req.http.User-Agent = regsub(req.http.User-Agent, {"/ \[(FB_IAB|FBAN|FBIOS|FB4A)/[^\]]+\]/i"}, "");

		# Electron/X.Y.Z` (see https://github.com/Financial-Times/polyfill-service/issues/1129)
		set req.http.User-Agent = regsub(req.http.User-Agent, {"/ Electron/[\d\.]+\d+/i"}, "");

        call useragent_parser;

        # Clone the original values for later modification. This helps when debugging as it let's us see what the useragent_parser function returned.
        set req.http.normalized_user_agent_family = req.http.useragent_parser_family;
        set req.http.normalized_user_agent_major_version = req.http.useragent_parser_major;
        set req.http.normalized_user_agent_minor_version = req.http.useragent_parser_minor;
        set req.http.normalized_user_agent_patch_version = req.http.useragent_parser_patch;

		set req.http.normalized_user_agent_patch_version = "0";

		set req.http.normalized_user_agent_family = std.tolower(req.http.useragent_parser_family);

		if (req.http.normalized_user_agent_family == "blackberry webkit") {
            set req.http.normalized_user_agent_family = "bb";
		}
		if (req.http.normalized_user_agent_family == "blackberry") {
            set req.http.normalized_user_agent_family = "bb";
		}
		if (req.http.normalized_user_agent_family == "pale moon (firefox variant)") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "pale moon") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "firefox mobile") {
            set req.http.normalized_user_agent_family = "firefox_mob";
		}
		if (req.http.normalized_user_agent_family == "firefox namoroka") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "firefox shiretoko") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "firefox minefield") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "firefox alpha") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "firefox beta") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "microb") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "mozilladeveloperpreview") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "iceweasel") {
            set req.http.normalized_user_agent_family = "firefox";
		}
		if (req.http.normalized_user_agent_family == "opera tablet") {
            set req.http.normalized_user_agent_family = "opera";
		}
		if (req.http.normalized_user_agent_family == "opera mobile") {
            set req.http.normalized_user_agent_family = "op_mob";
		}
		if (req.http.normalized_user_agent_family == "opera mini") {
            set req.http.normalized_user_agent_family = "op_mini";
		}
		if (req.http.normalized_user_agent_family == "chrome mobile") {
            set req.http.normalized_user_agent_family = "chrome";
		}
		if (req.http.normalized_user_agent_family == "chrome frame") {
            set req.http.normalized_user_agent_family = "chrome";
		}
		if (req.http.normalized_user_agent_family == "chromium") {
            set req.http.normalized_user_agent_family = "chrome";
		}
		if (req.http.normalized_user_agent_family == "headlesschrome") {
            set req.http.normalized_user_agent_family = "chrome";
		}
		if (req.http.normalized_user_agent_family == "ie mobile") {
            set req.http.normalized_user_agent_family = "ie_mob";
		}
		if (req.http.normalized_user_agent_family == "ie large screen") {
            set req.http.normalized_user_agent_family = "ie";
		}
		if (req.http.normalized_user_agent_family == "internet explorer") {
            set req.http.normalized_user_agent_family = "ie";
		}
		if (req.http.normalized_user_agent_family == "edge mobile") {
            set req.http.normalized_user_agent_family = "edge_mob";
		}
		if (req.http.normalized_user_agent_family == "uc browser") {
			if (req.http.normalized_user_agent_major_version == "9" && req.http.normalized_user_agent_minor_version == "9") {
                set req.http.normalized_user_agent_family = "ie";
                set req.http.normalized_user_agent_major_version = "10";
            }
		}
		if (req.http.normalized_user_agent_family == "chrome mobile ios") {
            set req.http.normalized_user_agent_family = "ios_chr";
		}
		if (req.http.normalized_user_agent_family == "mobile safari") {
            set req.http.normalized_user_agent_family = "ios_saf";
		}
		if (req.http.normalized_user_agent_family == "iphone") {
            set req.http.normalized_user_agent_family = "ios_saf";
		}
		if (req.http.normalized_user_agent_family == "iphone simulator") {
            set req.http.normalized_user_agent_family = "ios_saf";
		}
		if (req.http.normalized_user_agent_family == "mobile safari uiwebview") {
            set req.http.normalized_user_agent_family = "ios_saf";
		}
		if (req.http.normalized_user_agent_family == "mobile safari ui/wkwebview") {
            set req.http.normalized_user_agent_family = "ios_saf";
		}
		if (req.http.normalized_user_agent_family == "samsung internet") {
            set req.http.normalized_user_agent_family = "samsung_mob";
		}
		if (req.http.normalized_user_agent_family == "phantomjs") {
            set req.http.normalized_user_agent_family = "safari";
            set req.http.normalized_user_agent_major_version = "5";
        }
		if (req.http.normalized_user_agent_family == "yandex browser") {
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "10") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "37";
            }
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "8") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "36";
            }
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "7") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "35";
            }
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "5") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "34";
            }
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "4") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "33";
            }
			if (req.http.normalized_user_agent_major_version == "14" && req.http.normalized_user_agent_minor_version == "2") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "32";
            }
			if (req.http.normalized_user_agent_major_version == "13" && req.http.normalized_user_agent_minor_version == "12") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "30";
            }
			if (req.http.normalized_user_agent_major_version == "13" && req.http.normalized_user_agent_minor_version == "10") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "28";
            }
			if (req.http.normalized_user_agent_major_version == "17" && req.http.normalized_user_agent_minor_version == "9") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "60";
            }
		}
		if (req.http.normalized_user_agent_family == "opera") {
			if (req.http.normalized_user_agent_major_version == "20") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "33";
            }
			if (req.http.normalized_user_agent_major_version == "21") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "34";
            }
			if (req.http.normalized_user_agent_major_version == "22") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "35";
            }
			if (req.http.normalized_user_agent_major_version == "23") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "36";
            }
			if (req.http.normalized_user_agent_major_version == "24") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "37";
            }
			if (req.http.normalized_user_agent_major_version == "25") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "38";
            }
			if (req.http.normalized_user_agent_major_version == "26") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "39";
            }
			if (req.http.normalized_user_agent_major_version == "27") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "40";
            }
			if (req.http.normalized_user_agent_major_version == "28") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "41";
            }
			if (req.http.normalized_user_agent_major_version == "29") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "42";
            }
			if (req.http.normalized_user_agent_major_version == "30") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "43";
            }
			if (req.http.normalized_user_agent_major_version == "31") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "44";
            }
			if (req.http.normalized_user_agent_major_version == "32") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "45";
            }
			if (req.http.normalized_user_agent_major_version == "33") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "46";
            }
			if (req.http.normalized_user_agent_major_version == "34") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "47";
            }
			if (req.http.normalized_user_agent_major_version == "35") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "48";
            }
			if (req.http.normalized_user_agent_major_version == "36") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "49";
            }
			if (req.http.normalized_user_agent_major_version == "37") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "50";
            }
			if (req.http.normalized_user_agent_major_version == "38") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "51";
            }
			if (req.http.normalized_user_agent_major_version == "39") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "52";
            }
			if (req.http.normalized_user_agent_major_version == "40") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "53";
            }
			if (req.http.normalized_user_agent_major_version == "41") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "54";
            }
			if (req.http.normalized_user_agent_major_version == "42") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "55";
            }
			if (req.http.normalized_user_agent_major_version == "43") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "56";
            }
			if (req.http.normalized_user_agent_major_version == "44") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "57";
            }
			if (req.http.normalized_user_agent_major_version == "45") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "58";
            }
			if (req.http.normalized_user_agent_major_version == "46") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "59";
            }
			if (req.http.normalized_user_agent_major_version == "47") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "60";
            }
		}
		if (req.http.normalized_user_agent_family == "googlebot") {
			if (req.http.normalized_user_agent_major_version == "2" && req.http.normalized_user_agent_minor_version == "1") {
                set req.http.normalized_user_agent_family = "chrome";
                set req.http.normalized_user_agent_major_version = "41";
            }
		}
		if (req.http.normalized_user_agent_family == "edge") {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "edge_mob") {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "ie" && std.atoi(req.http.normalized_user_agent_major_version) >= 8) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "ie_mob" && std.atoi(req.http.normalized_user_agent_major_version) >= 11) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "chrome" && std.atoi(req.http.normalized_user_agent_major_version) >= 29) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "safari" && std.atoi(req.http.normalized_user_agent_major_version) >= 9) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "ios_saf" && std.atoi(req.http.normalized_user_agent_major_version) >= 9) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "ios_chr" && std.atoi(req.http.normalized_user_agent_major_version) >= 9) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "firefox" && std.atoi(req.http.normalized_user_agent_major_version) >= 38) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "firefox_mob" && std.atoi(req.http.normalized_user_agent_major_version) >= 38) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "android" && std.atoi(req.http.normalized_user_agent_major_version) >= 4 && std.atoi(req.http.normalized_user_agent_minor_version) >= 3) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "opera" && std.atoi(req.http.normalized_user_agent_major_version) >= 33) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "op_mob" && std.atoi(req.http.normalized_user_agent_major_version) >= 10) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "op_mini" && std.atoi(req.http.normalized_user_agent_major_version) >= 5) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "bb" && std.atoi(req.http.normalized_user_agent_major_version) >= 6) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (req.http.normalized_user_agent_family == "samsung_mob" && std.atoi(req.http.normalized_user_agent_major_version) >= 4) {
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
		if (!req.http.Normalized-User-Agent) {
            set req.http.normalized_user_agent_family = "other";
            set req.http.normalized_user_agent_major_version = "0";
            set req.http.normalized_user_agent_minor_version = "0";
            set req.http.Normalized-User-Agent = req.http.normalized_user_agent_family "/"  req.http.normalized_user_agent_major_version "." req.http.normalized_user_agent_minor_version "." req.http.normalized_user_agent_patch_version;
        }
    }
}