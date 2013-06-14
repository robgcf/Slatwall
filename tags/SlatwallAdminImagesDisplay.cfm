<cfif thisTag.executionMode is "start">
	<cfparam name="attributes.hibachiScope" type="any" default="#request.context.fw.getHibachiScope()#" />
	<cfparam name="attributes.object" type="any" />
	
	<cfoutput>
		<ul class="thumbnails">
				<cfloop array="#attributes.object.getImages()#" index="image">
				<li class="span3">
    				<div class="thumbnail">
    					<a href="#image.getResizedImagePath(width=210, height=210)#" target="_blank">
							#image.getResizedImage(width=210, height=210)#
						</a>
						<hr />
						<div class="small em image-caption">#image.getImagePath()#</div>
						<cf_HibachiActionCaller action="admin:entity.detailImage" querystring="imageID=#image.getImageID()#" class="btn" iconOnly="true" icon="eye-open" />
						<cf_HibachiActionCaller action="admin:entity.editImage" querystring="imageID=#image.getImageID()#" class="btn" iconOnly="true" icon="pencil" />
						<cf_HibachiActionCaller action="admin:entity.deleteImage" querystring="imageID=#image.getImageID()#&#attributes.object.getPrimaryIDPropertyName()#=#attributes.object.getPrimaryIDValue()#&redirectAction=#request.context.slatAction#" class="btn" iconOnly="true" icon="trash" confirm="true" />				
    				</div>
  				</li>
			</cfloop>
		</ul>
		<cf_HibachiActionCaller action="admin:entity.createImage" querystring="#attributes.object.getPrimaryIDPropertyName()#=#attributes.object.getPrimaryIDValue()#&objectName=#attributes.object.getClassName()#&redirectAction=#request.context.slatAction#" modal="true" class="btn" icon="plus" />
	</cfoutput>
</cfif>