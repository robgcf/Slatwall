<!---

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC
	
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
    
    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
	
    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your 
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms 
    of your choice, provided that you follow these specific guidelines: 

	- You also meet the terms and conditions of the license of each 
	  independent module 
	- You must not alter the default display of the Slatwall name or logo from  
	  any part of the application 
	- Your custom code must not alter or create any files inside Slatwall, 
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets 
	the above guidelines as a combined work under the terms of GPL for this program, 
	provided that you include the source code of that other code when and as the 
	GNU GPL requires distribution of source code.
    
    If you modify this program, you may extend this exception to your version 
    of the program, but you are not obligated to do so.

Notes:

--->
<cfcomponent extends="HibachiService" persistent="false" accessors="true" output="false">
	
	<cfproperty name="templateService" />
	
		
	<!--- ===================== START: Logical Methods =========================== --->
		
	<cffunction name="sendEmail" returntype="void" access="public">
		<cfargument name="email" type="any" required="true" />
		
		<!--- Send Multipart E-mail --->
		<cfif len(arguments.email.getEmailBodyHTML()) && len(arguments.email.getEmailBodyText())>
			<cfmail to="#arguments.email.getEmailTo()#"
				from="#arguments.email.getEmailFrom()#"
				subject="#arguments.email.getEmailSubject()#"
				cc="#arguments.email.getEmailCC()#"
				bcc="#arguments.email.getEmailBCC()#"
				charset="utf-8">
				<cfmailpart type="text/plain">
					<cfoutput>#arguments.email.getEmailBodyText()#</cfoutput>
				</cfmailpart>
				<cfmailpart type="text/html">
					<html>
						<body><cfoutput>#arguments.email.getEmailBodyHTML()#</cfoutput></body>
					</html>
				</cfmailpart>
			</cfmail>
		<!--- Send HTML Only E-mail --->
		<cfelseif len(arguments.email.getEmailBodyHTML())>
			<cfmail to="#arguments.email.getEmailTo()#"
				from="#arguments.email.getEmailFrom()#"
				subject="#arguments.email.getEmailSubject()#"
				cc="#arguments.email.getEmailCC()#"
				bcc="#arguments.email.getEmailBCC()#"
				charset="utf-8"
				type="text/html">
				<html>
					<body><cfoutput>#arguments.email.getEmailBodyHTML()#</cfoutput></body>
				</html>
			</cfmail>
		<!--- Send Text Only E-mail --->
		<cfelseif len(arguments.email.getEmailBodyText())>
			<cfmail to="#arguments.email.getEmailTo()#"
				from="#arguments.email.getEmailFrom()#"
				subject="#arguments.email.getEmailSubject()#"
				cc="#arguments.email.getEmailCC()#"
				bcc="#arguments.email.getEmailBCC()#"
				charset="utf-8"
				type="text/plain">
				<cfoutput>#arguments.email.getEmailBodyText()#</cfoutput>
			</cfmail>
		</cfif>
		
		<!--- If the email is set to be saved, then we persist to the DB --->
		<cfif arguments.email.getLogEmailFlag()>
			<cfset getHibachiDAO().save(arguments.email) />
		</cfif>
	</cffunction>
		
	<cffunction name="sendEmailQueue" returntype="void" access="public">
		
		<cfset var email = "" />
		
		<!--- Loop over the queue --->
		<cfloop array="#getHibachiScope().getEmailQueue()#" index="email">
			
			<!--- Send the email --->
			<cfset sendEmail(email) />
		</cfloop>
		
		<!--- Clear out the queue --->
		<cfset getHibachiScope().setEmailQueue( [] ) />
	</cffunction>
		
	<cffunction name="getEmailTemplateFileOptions" output="false" access="public">
		<cfargument name="object" type="string" required="true" />
		
		<cfset var dir = "" />
		<cfset var fileOptions = [] />
		
		<cfif directoryExists("#getApplicationValue('applicationRootMappingPath')#/templates/email/#arguments.object#")>
			<cfdirectory action="list" directory="#getApplicationValue('applicationRootMappingPath')#/templates/email/#arguments.object#" name="dir" />
			<cfloop query="dir">
				<cfif listLast(dir.name, '.') eq 'cfm'>
					<cfset arrayAppend(fileOptions, dir.name) />
				</cfif>
			</cfloop>
		</cfif>
		<cfif directoryExists("#getApplicationValue('applicationRootMappingPath')#/custom/templates/email/#arguments.object#")>
			<cfdirectory action="list" directory="#getApplicationValue('applicationRootMappingPath')#/custom/templates/email/#arguments.object#" name="dir" />
			<cfloop query="dir">
				<cfif listLast(dir.name, '.') eq 'cfm' and !arrayFind(fileOptions, dir.name)>
					<cfset arrayAppend(fileOptions, dir.name) />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn fileOptions />
	</cffunction>
	
	<cffunction name="getEmailTemplateOptions" access="public" returntype="array">
		<cfargument name="emailTemplateObject" type="string" required="true">
		
		<cfset var sl = this.getEmailTemplateSmartList() />
		<cfset sl.addFilter('emailTemplateObject', arguments.emailTemplateObject) />
		<cfset sl.addSelect('emailTemplateName', 'name') />
		<cfset sl.addSelect('emailTemplateID', 'value') />
		
		<cfreturn sl.getRecords() />
	</cffunction>
	
	<!--- =====================  END: Logical Methods ============================ --->
	
	<cfscript>
		
	public void function generateAndSendFromEntityAndEmailTemplateID( required any entity, required any emailTemplateID ) {
		var email = this.newEmail();
		var emailData = {
			emailTemplateID = arguments.emailTemplateID
		};
		emailData[ arguments.entity.getPrimaryIDPropertyName() ] = arguments.entity.getPrimaryIDValue();
		email = this.processEmail(email, emailData, 'createFromTemplate');
		email = this.processEmail(email, {}, 'addToQueue');
	}
	
	</cfscript>
	
	<!--- ===================== START: DAO Passthrough =========================== --->
	
	<!--- ===================== START: DAO Passthrough =========================== --->
	
	<!--- ===================== START: Process Methods =========================== --->
	
	<cfscript>
	
	public any function processEmail_createFromTemplate(required any email, required struct data) {
		
		if(structKeyExists(arguments.data, "emailTemplateID")) {
			var emailTemplate = getTemplateService().getEmailTemplate( arguments.data.emailTemplateID );
			
			if(!isNull(emailTemplate)) {
				var templateObjectIDProperty = getPrimaryIDPropertyNameByEntityName(emailTemplate.getEmailTemplateObject());
				var templateObject = javaCast('null','');
				
				if(structKeyExists(arguments.data, emailTemplate.getEmailTemplateObject()) && isObject(arguments.data[emailTemplate.getEmailTemplateObject()])) {
					// Set the template object from the passed object
					templateObject = arguments.data[ emailTemplate.getEmailTemplateObject() ];
					
				} else if(structKeyExists(arguments.data, templateObjectIDProperty)) {
					// Set the template object from the passed ID
					templateObject = getServiceByEntityName( emailTemplate.getEmailTemplateObject() ).invokeMethod("get#emailTemplate.getEmailTemplateObject()#", {1=arguments.data[ templateObjectIDProperty ]});
				}
				
				if(!isNull(templateObject) && isObject(templateObject) && structKeyExists(templateObject, "stringReplace")) {
						
					// Setup the email values
					arguments.email.setEmailTo( templateObject.stringReplace( emailTemplate.setting('emailToAddress'), false, true ) );
					arguments.email.setEmailFrom( templateObject.stringReplace( emailTemplate.setting('emailFromAddress'), false, true ) );
					arguments.email.setEmailCC( templateObject.stringReplace( emailTemplate.setting('emailCCAddress'), false, true ) );
					arguments.email.setEmailBCC( templateObject.stringReplace( emailTemplate.setting('emailBCCAddress'), false, true ) );
					arguments.email.setEmailSubject( templateObject.stringReplace( emailTemplate.setting('emailSubject'), false, true ) );
					arguments.email.setEmailBodyHTML( templateObject.stringReplace( emailTemplate.getEmailBodyHTML() ) );
					arguments.email.setEmailBodyText( templateObject.stringReplace( emailTemplate.getEmailBodyText() ) );
					
					var templateFileResponse = "";
					var templatePath = getTemplateService().getTemplateFileIncludePath(templateType="email", objectName=emailTemplate.getEmailTemplateObject(), fileName=emailTemplate.getEmailTemplateFile());
					
					local.email = arguments.email;
					local.emailData = arguments.data;
					local[ emailTemplate.getEmailTemplateObject() ] = templateObject;
					
					if(len(templatePath)) {
						savecontent variable="templateFileResponse" {
							include '#templatePath#';
						}
					}
					
					if(len(templateFileResponse) && !structKeyExists(local.emailData, "bodyHTML")) {
						local.emailData.emailBodyHTML = templateFileResponse;
					}
					
					arguments.email.populate( local.emailData );
				}
					
				// Take all the Settings & String Replace on them (to, from, cc, bcc, subject, bodyHTML, bodyText)
				
			}
		}
		
		return arguments.email;
	}
	
	public any function processEmail_addToQueue(required any email, required struct data) {
		// Populate the email with any data that came in
		arguments.email.populate( arguments.data );
		
		// Make sure that the email isn't voided, and that it has a To, CC, or BCC, as well as a subject
		if( ( !isBoolean(arguments.email.getVoidSendFlag()) || !arguments.email.getVoidSendFlag() )
			&& 
			(
				(!isNull(arguments.email.getEmailTo()) && len(arguments.email.getEmailTo()))
			  ||
			  	(!isNull(arguments.email.getEmailCC()) && len(arguments.email.getEmailCC()))
			  ||
			  	(!isNull(arguments.email.getEmailBCC()) && len(arguments.email.getEmailBCC()))
			)
			&&
			!isNull(arguments.email.getEmailSubject())
			&&
			len(arguments.email.getEmailSubject())
		) {
			// Append the email to the email queue
			arrayAppend(getHibachiScope().getEmailQueue(), arguments.email);	
		}
		
		return arguments.email;
	}
		
	</cfscript>
	
	<!--- =====================  END: Process Methods ============================ --->
	
	<!--- ====================== START: Save Overrides =========================== --->
	
	<!--- ======================  END: Save Overrides ============================ --->
	
	<!--- ==================== START: Smart List Overrides ======================= --->
	
	<!--- ====================  END: Smart List Overrides ======================== --->
	
	<!--- ====================== START: Get Overrides ============================ --->
	
	<!--- ======================  END: Get Overrides ============================= --->
	
</cfcomponent>

