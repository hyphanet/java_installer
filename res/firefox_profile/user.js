user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "http://127.0.0.1:8888");
user_pref("app.update.enabled", false);
user_pref("extensions.update.enabled", false);
user_pref("browser.search.update", false);
user_pref("config.lockdown.disable_extensions", true);
user_pref("extensions.update.notifyUser", false);
user_pref("javascript.enabled", false);
user_pref("security.enable_java", false);
// See 2644: disable history
user_pref("browser.history_expire_days", 0);
user_pref("browser.history_expire_days.mirror", 0);
user_pref("browser.formfill.enable", false);
user_pref("browser.download.manager.retention", 0);
// See 1124: Possible hint on how to not get USK's googled when miss-pasted
user_pref("keyword.enabled", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.search.update", false);
// Obvious performance tweaks
user_pref("network.http.max-connections", 200);
user_pref("network.http.max-connections-per-server", 200);
user_pref("network.http.max-persistent-connections-per-server", 200);
user_pref("network.http.max-persistent-connections-per-proxy", 200);
// Pipelining
user_pref("network.http.pipelining", false);
user_pref("network.http.proxy.pipelining", false);
// Cookies
user_pref("network.cookie.blockFutureCookies", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("network.cookie.lifetimePolicy", 2);
user_pref("network.cookie.alwaysAcceptSessionCookies", false);
user_pref("network.cookie.enableForCurrentSessionOnly", false);
// Don't remember passwords
user_pref("signon.rememberSignons", false);
// Disable safebrowsing
user_pref("browser.safebrowsing.enabled", false);
// See 1941: Firefox GoBrowsing
user_pref("browser.safebrowsing.remoteLookups", false);
// We don't want to import anything
user_pref("network.cookie.prefsMigrated", true);
// We don't want the popup when we click submit
user_pref("security.warn_entering_secure", false);
user_pref("security.warn_submit_insecure", false);
// Select the skin
user_pref("general.skins.selectedSkin", "BlackJapanMAX");
// Chose the default charset
user_pref("intl.charsetmenu.browser.cache", "UTF-8");
// Prevent plugin installation from that profile
user_pref("xpinstall.enabled", false);
user_pref("xpinstall.whitelist.add", "");
user_pref("plugin.scan.4xPluginFolder", false);
user_pref("plugin.scan.SunJRE", false);
// Disable caching
user_pref("browser.cache.disk.capacity", 0);
// Use the private-data-cleaning stuff
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.sanitize.promptOnSanitize", false);
user_pref("privacy.item.history", true);
user_pref("privacy.item.downloads", true);
user_pref("privacy.item.formdata", true);
user_pref("privacy.item.cache", true);
user_pref("privacy.item.cookies", true);
user_pref("privacy.item.passwords", true);
user_pref("privacy.item.sessions", true);
