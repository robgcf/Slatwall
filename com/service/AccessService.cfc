/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component extends="Slatwall.com.service.BaseService" persistent="false" accessors="true" output="false" {
	
	public boolean function hasAccess(required any cmsContentIDPath,cmsCategoryIDs) {
		// make sure there is restricted content in the system before doing any check
		if(!getService("contentService").restrictedContentExists()) {
			return true;
		}
		// get restricted content by path
		var restrictedContent = getService("contentService").getRestrictedContentByPath(arguments.cmsContentIDPath);
		if(isNull(restrictedContent)) {
			return true;
		}
		// get the current content
		var thisContent = getService("contentService").getContentByCmsContentID(listLast(arguments.cmsContentIDPath));
		// check if purchase is allowed for this content
		if(!isNull(thisContent.getAllowPurchaseFlag()) && thisContent.getAllowPurchaseFlag()) {
			// check if the content was purchased
			var accountContentAccessSmartList = getAccountContentAccessSmartList();
			accountContentAccessSmartList.addFilter(propertyIdentifier="account_accountID", value=$.slatwall.getCurrentAccount().getAccountID());
			accountContentAccessSmartList.addFilter(propertyIdentifier="accessContents_contentID", value=thisContent.getContentID());
			if(accountContentAccessSmartList.getRecordCount()) {
				return true;
			}
		}
		// check if this content is part of subscription access
		for(var subscriptionUsageBenefitAccount in $.slatwall.getCurrentAccount().getSubscriptionUsageBenefitAccounts()) {
			if(subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().hasContent(thisContent)) {
				return true;
			}
		}
		// check if any of this content's category is part of subscription access
		var categories = getService("contentService").getCategoriesByCmsCategoryIDs(arguments.cmsCategoryIDs);
		for(var subscriptionUsageBenefitAccount in $.slatwall.getCurrentAccount().getSubscriptionUsageBenefitAccounts()) {
			for(var category in categories) {
				if(subscriptionUsageBenefitAccount.getSubscriptionUsageBenefit().hasCategory(category)) {
					return true;
				}
			}
		}
		return false;
	}
	
	public string function createAccessCode() {
		// TODO: access code generation
		
	}
	
}