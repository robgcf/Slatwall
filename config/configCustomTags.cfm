<cfset arrayAppend(this.customTagPathsArray, "#replace(replace(getDirectoryFromPath(getCurrentTemplatePath()),"\","/","all"), "/config/", "/tags")#") />