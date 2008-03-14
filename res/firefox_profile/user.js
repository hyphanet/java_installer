user_pref("browser.startup.homepage", "http://127.0.0.1:8888");
user_pref("javascript.enabled", false);
user_pref("security.enable_java", false);
// See 1124: Possible hint on how to not get USK's googled when miss-pasted
user_pref("keyword.enabled", false);
user_pref("browser.search.suggest.enabled", false);
// Obvious performance tweaks
user_pref("network.http.max-connections", 200);
user_pref("network.http.max-connections-per-server", 200);
user_pref("network.http.max-persistent-connections-per-server", 100);
user_pref("network.http.max-persistent-connections-per-proxy", 100);
// Pipelining
user_pref("network.http.pipelining", true);
user_pref("network.http.proxy.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 50);
// Cookies
user_pref("network.cookie.blockFutureCookies", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("network.cookie.lifetimePolicy", 2);
user_pref("network.cookie.alwaysAcceptSessionCookies", false);
user_pref("network.cookie.enableForCurrentSessionOnly", false);
// Disable safebrowsing
user_pref("browser.safebrowsing.enabled", false);
// See 1941: Firefox GoBrowsing
user_pref("browser.safebrowsing.remoteLookups", false);
