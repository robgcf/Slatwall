/*

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

*/
component accessors="true" output="false" displayname="Avatax" implements="Slatwall.integrationServices.TaxInterface" extends="Slatwall.integrationServices.BaseTax" {

	public any function getTaxRates(required any requestBean) {

		// Create new TaxRatesResponseBean to be populated with XML Data retrieved from Quotation Resquest
		var responseBean = new Slatwall.model.transient.tax.TaxRatesResponseBean();


		// Loop over each unique tax address
		for(var taxAddressID in arguments.requestBean.getTaxRateItemRequestBeansByAddressID()) {

			var addressTaxRequestItems = arguments.requestBean.getTaxRateItemRequestBeansByAddressID()[ taxAddressID ];

			var requestDataStruct = {
				CustomerCode = 1, //arguments.requestBean.getAccount().getShortReferenceID( true );
				DocDate = dateFormat(now(),'yyyy-mm-dd'),
				DocCode = 1, //arguments.requestBean.getOrder().getShortReferenceID( true );
				DocType = 'SalesInvoice',
				Addresses = [
					{
						AddressCode = 1,
						Line1 = addressTaxRequestItems[1].getTaxStreetAddress(),
						Line2 = addressTaxRequestItems[1].getTaxStreet2Address(),
						City = addressTaxRequestItems[1].getTaxCity(),
						Region = addressTaxRequestItems[1].getTaxStateCode(),
						Country = addressTaxRequestItems[1].getTaxCountryCode(),
						PostalCode = addressTaxRequestItems[1].getTaxPostalCode()
					},
					{
						AddressCode = 2,
						Line1 = setting('sourceStreetAddress'),
						Line2 = setting('sourceStreetAddress2'),
						City = setting('sourceCity'),
						Region = setting('sourceRegion'),
						Country = setting('sourceCountry'),
						PostalCode = setting('sourcePostalCode')
					}
				],
				Lines = []
			};
			
			
			var count = 0;
			for(var item in addressTaxRequestItems) {
				count++;
				
				var itemData = {};
				itemData.LineNo = count;
				itemData.DestinationCode = 1;
				itemData.OriginCode = 2;
				itemData.ItemCode = item.getOrderItemID();
				itemData.TaxCode = 'NT';
				itemData.Description = 'Item Description';
				itemData.Qty = item.getQuantity();
				itemData.Amount = item.getExtendedPriceAfterDiscount();
				
				arrayAppend(requestDataStruct.Lines, itemData);
			}
			
			var base64Auth = toBase64("#setting('accountNo')#:#setting('accessKey')#");
			
			// Setup Request to push to Avatax
	        var httpRequest = new http();
	        httpRequest.setMethod("POST");
			httpRequest.setUrl("https://avatax.avalara.net/1.0/tax/get");
			httpRequest.addParam(type="header", name="Content-type", value="application/json");
			httpRequest.addParam(type="header", name="Content-length", value="#len(serializeJSON(requestDataStruct))#");
			httpRequest.addParam(type="header", name="Authorization", value="Basic #base64Auth#");
			httpRequest.addParam(type="body", value=serializeJSON(requestDataStruct));

			var requestData = DeserializeJSON(httpRequest.send().getPrefix().fileContent);
			
		//writeDump(var=requestData, label="requestData", abort=true);

			var taxRate = 0;

			for (var x = 1; x < ArrayLen(requestData.TaxLines); x++ ) {
				
				if ( requestData.TaxLines[x].TaxCode != "NT" ) {  // NT = Non-Taxable?
						
					taxRate = NumberFormat(requestData.TaxLines[x].Rate);

					responseBean.addTaxRateItem(
						orderItemId = requestDataStruct.CustomerCode,
						taxAmount = LSParseNumber(requestData.totalAmount) * taxRate, 
						taxRate = taxRate 
					);
					
				}
			}

		}

		return responseBean;
	}

}