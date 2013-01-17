﻿/*

    Slatwall - An Open Source eCommerce Platform
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
component displayname="Task" entityname="SlatwallTask" table="SlatwallTask" persistent="true" accessors="true" extends="BaseEntity" {
	
	// Persistent Properties
	property name="taskID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="activeFlag" ormtype="boolean" formatType="yesno";
	property name="taskName" ormtype="string";
	property name="taskMethod" ormtype="string" formFieldType="select";
	property name="taskUrl" ormtype="string";
	property name="runningFlag" ormtype="boolean" formatType="yesno";
	property name="timeout" ormtype="int" ;

	
	// Related Object Properties (many-to-one)
	
	
	// Related Object Properties (one-to-many)
	property name="taskHistory" cfc="TaskHistory" type="array" fieldtype="one-to-many" fkcolumn="taskID" cascade="all-delete-orphan" inverse="true";
	property name="taskSchedules" singularname="taskSchedule" cfc="TaskSchedule" type="array" fieldtype="one-to-many" fkcolumn="taskID" cascade="all-delete-orphan" inverse="true";
	
	// Related Object Properties (many-to-many)
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit Properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non-Persistent Properties
	property name="taskMethodOptions" persistent="false";

	public array function getTaskMethodOptions() {
		var options = [
			{name="url", value="url"},
			{name="Renew Subscription Usage", value="renewSubscriptionUsage"},
			{name="Subscription Renewal Reminder", value="subscriptionUsageRenewalReminder"}
		];
		return options;
	}
	// ============ START: Non-Persistent Property Methods =================
	
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Task history (one-to-many)    
	public void function addTaskHistory(required any taskHistory) {    
		arguments.taskHistory.settaskHistoryID( this );    
	}    
	public void function removeTaskHistory(required any taskHistory) {    
		arguments.taskHistory.removetaskHistoryID( this );    
	}
    	
	// =============  END:  Bidirectional Helper Methods ===================

	// ================== START: Overridden Methods ========================
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}