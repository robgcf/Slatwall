<cfftp action="putfile" server="#integration.setting('syncFTPSite')#" username="#integration.setting('syncFTPSiteUsername')#" password="#integration.setting('syncFTPSitePassword')#" port="#integration.setting('syncFTPSitePort')#" remotefile="#remoteFullFilePath#" localfile="#localFullFilePath#" secure="#integration.setting('syncFTPSiteSecure')#">