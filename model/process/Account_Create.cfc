component output="false" accessors="true" extends="HibachiProcess" {

	// Injected Entity
	property name="account";

	// Data Properties
	property name="firstName" hb_rbKey="entity.account.firstName";
	property name="lastName" hb_rbKey="entity.account.lastName";
	property name="company" hb_rbKey="entity.account.company";
	property name="phoneNumber";
	property name="emailAddress";
	property name="emailAddressConfirm";
	property name="createAuthenticationFlag" hb_sessionDefault="1";
	property name="password";
	property name="passwordConfirm";
	
	public boolean function getCreateAuthenticationFlag() {
		if(!structKeyExists(variables, "createAuthenticationFlag")) {
			variables.createAuthenticationFlag = getPropertySessionDefault("createAuthenticationFlag");
		}
		return variables.createAuthenticationFlag;
	}
	
	public boolean function getEmailAddressNotInUseFlag() {
		if(!isNull(getEmailAddress())) {
			return getService("accountService").getEmailAddressNotInUseFlag( emailAddress=getEmailAddress() );	
		}
		return true;
	}
	
}