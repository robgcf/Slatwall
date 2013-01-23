/*

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
component displayname="Stock Adjustment Delivery" entityname="SlatwallStockAdjustmentDelivery" table="SlatwallStockAdjustmentDelivery" persistent="true" accessors="true" output="false" extends="BaseEntity" {
	
	// Persistent Properties
	property name="stockAdjustmentDeliveryID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="deliveryOpenDateTime" ormtype="timestamp";
	property name="deliveryCloseDateTime" ormtype="timestamp";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Slatwall.model.entity.Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Slatwall.model.entity.Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Related Object Properties
	property name="stockAdjustment" cfc="Slatwall.model.entity.StockAdjustment" fieldtype="many-to-one" fkcolumn="stockAdjustmentID";
	property name="stockAdjustmentDeliveryItems" singularname="stockAdjustmentDeliveryItem" cfc="Slatwall.model.entity.StockAdjustmentDeliveryItem" fieldtype="one-to-many" fkcolumn="stockAdjustmentDeliveryID" cascade="all-delete-orphan" inverse="true";
	
	
	public any function getTotalQuantityDelivered() {
		var totalDelivered = 0;
		for(var i=1; i<=arrayLen(getStockAdjustmentDeliveryItems()); i++) {
			totalDelivered += getStockAdjustmentDeliveryItems()[i].getQuantity();
		}
		return totalDelivered;
	}
	
	// StockAdjustmentDeliveryItems (one-to-many)
	
	public void function addStockAdjustmentDeliveryItem(required StockAdjustmentDeliveryItem StockAdjustmentDeliveryItem) {
	   arguments.stockAdjustmentDeliveryItem.setStockAdjustmentDelivery(this);
	}
	
	public void function removeStockAdjustmentDeliveryItem(required StockAdjustmentDeliveryItem StockAdjustmentDeliveryItem) {
	   arguments.stockAdjustmentDeliveryItem.removeStockAdjustmentDelivery(this);
	}
    
    
    // ============ START: Non-Persistent Property Methods =================
	
	// ============  END:  Non-Persistent Property Methods =================
	
	// ============= START: Bidirectional Helper Methods ===================
	
	// =============  END:  Bidirectional Helper Methods ===================
	
	// ================== START: Overridden Methods ========================
	
	// ==================  END:  Overridden Methods ========================
		
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
}