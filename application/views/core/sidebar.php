
<div class="sidebar">
<!--
	<ul>
	<? /*
		$headings = $sidebar->get_nav_headings();
		foreach($headings as $navItem) {
			echo '<li><a href="'.$navItem->get_link().'">'.$navItem->get_title().'</a></li>';
			if($navItem->get_views()) {
			
				echo '<ul>';
				foreach(array_keys($navItem->get_views()) as $view) {
					if(is_array($navItem->get_view_link($view))) {
						$options = $navItem->get_view_link($view);
						echo '<li><a href="'.$options['Base'].'">'.$view.'</a></li>';
						echo '<ul>';
						foreach(array_keys($options) as $option) {
							if($option != 'Base') {
								echo '<li><a href="'.$options[$option].'">'.$option.'</a></li>';
							}
						}
						echo '</ul>';
					}
					else {
						echo '<li><a href="'.$navItem->get_view_link($view).'">'.$view.'</a></li>';
					}
				}
				echo '</ul>';
			}
		} */
	?>
	<ul>
-->
	<div id="sidetree">
		<ul class="treeview" id="tree">
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/systems/"><span><strong>Systems</strong></span></a>
				<ul style="display: none;">
					<?echo $sidebar->load_owned_system_view_data();?>
					<li class="expandable last"><div class="hitarea expandable-hitarea"></div><span><strong>Other</strong></span>
						<ul style="display: none;">
							<?echo $sidebar->load_other_system_view_data();?>
						</ul>
					</li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Metahosts</strong></span>
				<ul style="display: none;">
					<?echo $sidebar->load_owned_metahost_view_data();?>
					<li class="expandable last"><div class="hitarea expandable-hitarea"></div><a href="/metahosts/all">Other</a>
						<ul style="display: none;">
							<?echo $sidebar->load_other_metahost_view_data();?>
						</ul>
					</li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Statistics</strong></span>
				
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Resources</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/resources/keys/">Keys</a>
						<ul style="display: none;">
							<?
							echo $sidebar->load_owned_key_view_data();
							echo $sidebar->load_other_key_view_data();
							?>
						</ul>
					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/resources/zones/">Zones</a>
						<ul style="display: none;">
							<?
							echo $sidebar->load_owned_zone_view_data();
							echo $sidebar->load_other_zone_view_data();
							?>
						</ul>
					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/resources/subnets/">Subnets</a>
						<ul style="display: none;">
							<?
							echo $sidebar->load_owned_subnet_view_data();
							echo $sidebar->load_other_subnet_view_data();
							?>
						</ul>
					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/resources/ranges/">Ranges</a>
						<ul style="display: none;">
							<?
							echo $sidebar->load_range_view_data();
							?>
						</ul>
					</li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Administration</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/admin/configuration/view/site">Site Configuration</a></li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>DHCP</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/dhcp/classes">Classes</a></li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/dhcp/options/view/global">Global Options</a></li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Reference</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/reference/api">API</a></li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/reference/reference/help">Help</a></li>
				</ul>
			</li>
			
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>Output</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/output/view/dhcp.conf">DHCPD Config</a></li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/output/view/fw_default_queue">Firewall Default Queue</a></li>
				</ul>
			</li>
		<!--
			<li class="expandable"><div class="hitarea expandable-hitarea"></div><span><strong>City Services</strong></span>
				<ul style="display: none;">
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/assessment/index.cfm">Assessment</a>
					<ul style="display: none;">
						<li><a href="?/assessment/assessment_faqs.cfm">Assessment FAQs</a></li>

						<li><a href="?/assessment/property_assessment_notices.cfm">2007 Property Assessment Notices</a></li>
						<li><a href="?http://www.creb.com/" target="_blank">CREB</a></li>
						<li><a href="?/assessment/non_residential_assessment_tax_comparisons.cfm">Non-Residential Assessment / Tax Comparisons</a></li>
						<li><a href="?/assessment/how_to_file_a_complaint.cfm">How to File a Complaint</a></li>
						<li class="last"><a href="?/assessment/supplementary_assessment_tax.cfm">Supplementary Assessment and Tax</a></li>
					</ul>

					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/building_development/index.cfm">Building &amp; Development </a>
					<ul style="display: none;">
						<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/building_inspections/index.cfm">Building Inspections</a>
						<ul style="display: none;">
							<li><a href="?/building_inspections/builder_forums.cfm">Builder Forums</a></li>

							<li><a href="?/building_inspections/contact_us.cfm">Contact Us</a></li>
							<li><a href="?/building_inspections/contractor_notices.cfm">Contractor Notices</a></li>
							<li><a href="?/building_inspections/inspector_guidelines.cfm">Inspector Guidelines</a></li>
							<li><a href="?/building_inspections/links.cfm">Links</a></li>
							<li class="expandable lastExpandable"><div class="hitarea expandable-hitarea lastExpandable-hitarea"></div><a href="?/building_inspections/statistics_2007.cfm">Statistics</a>
							<ul style="display: none;">

								<li><a href="?/building_inspections/statistics_2006.cfm">Statistics 2006</a></li>
								<li class="last"><a href="?/building_inspections/statistics_2005.cfm">Statistics 2005</a></li>
							</ul>
							</li>
						</ul>
						</li>
						<li class="expandable"><div class="hitarea expandable-hitarea"></div><a title="City Infrastructure" href="?/building_development/city_infrastructure/index.cfm">City Infrastructure</a>

						<ul style="display: none;">

							<li><a href="?/building_development/city_infrastructure/roadway_improvement.cfm">Roadway Improvement</a></li>
							<li><a href="?/building_development/city_infrastructure/traffic.cfm">Traffic</a></li>
							<li><a href="?/building_development/city_infrastructure/transportation_planning.cfm">Transportation &amp; Infrastructure Planning</a></li>
							<li class="last"><a href="?/building_development/city_infrastructure/water_sewer_construction.cfm">Water &amp; Sewer Construction</a></li>

						</ul>
						</li>
						<li class="expandable"><div class="hitarea expandable-hitarea"></div><a title="Commercial/Industrial Development" href="?/building_development/commercial_industrial_development/index.cfm">Commercial / Industrial / Multi-Family Development</a>
						<ul style="display: none;">
							<li><a title="Call Before You Dig" href="?/building_development/commercial_industrial_development/call_before_you_dig.cfm">Call Before You Dig</a></li>
							<li><a title="New Development" href="?/building_development/commercial_industrial_development/new_development.cfm">New Development</a></li>
							<li><a title="Existing Development" href="?/building_development/commercial_industrial_development/existing_development.cfm">Existing Development</a></li>

							<li><a title="Signage" href="?/building_development/commercial_industrial_development/signage.cfm">Signage</a></li>
							<li><a title="Notice of Development" href="?/building_development/planning/notice_of_development/notice_of_development.cfm">Notice of Development</a></li>
							<li><a title="Appeals" href="?/public_meetings/appeals/index.cfm">Appeals</a></li>
							<li><a title="Customer Feedback" href="?/building_development/commercial_industrial_development/customer_feedback.cfm">Customer Feedback</a></li>
							<li><a title="Certificate of Compliance" href="?/building_development/commercial_industrial_development/certificate_of_compliance.cfm">Certificate of Compliance</a></li>
							<li><a title="Permit Applications &amp; Forms" href="?/building_development/commercial_industrial_development/permit_applications_forms.cfm">Permit Applications &amp; Forms</a></li>

							<li class="last"><a title="Fees" href="?/building_development/commercial_industrial_development/fees.cfm">Fees</a></li>
						</ul>
						</li>
						<li class="expandable lastExpandable"><div class="hitarea expandable-hitarea lastExpandable-hitarea"></div> <a title="Residential Development" href="?/building_development/residential_development/index.cfm">Residential Development</a>
						<ul style="display: none;">
							<li><a title="Call Before You Dig" href="?/building_development/residential_construction/building_permit_requirements.cfm">Building Permit Requirements</a></li>
							<li><a title="New Development" href="?/building_development/residential_construction/new_homes.cfm">New Homes</a></li>

							<li><a title="Existing Development" href="?/building_development/residential_construction/basements.cfm">Basements</a></li>
							<li><a title="Signage" href="?/building_development/commercial_industrial_development/call_before_you_dig.cfm">Call Before You Dig</a></li>
							<li><a title="Decks" href="?/building_development/residential_development/decks.cfm">Decks</a></li>
							<li><a title="Detached Garages or Accessory Building" href="?/building_development/residential_development/detached_garages_or_accessory_building.cfm">Detached Garages or Accessory Building</a></li>
							<li><a title="Grading" href="?/building_development/residential_development/grading.cfm">Grading</a></li>
							<li><a title="Fences" href="?/building_development/residential_development/fences.cfm">Fences</a></li>

							<li><a title="Applications, Permits &amp; Checklists" href="?/building_development/residential_development/applications_permits_checklists.cfm">Applications, Permits &amp; Checklists</a></li>
							<li><a title="Certificate of Compliance" href="?/building_development/commercial_industrial_development/certificate_of_compliance.cfm">Certificate of Compliance</a></li>
							<li><a title="Fees" href="?/building_development/residential_development/fees.cfm">Fees</a></li>
							<li><a title="Notice of Development" href="?/building_development/planning/notice_of_development/notice_of_development.cfm">Notice of Development</a></li>
							<li class="last"><a title="Street Addresses for New Construction" href="?/gis/index.cfm">Street Addresses for New Construction</a></li>

						</ul>
						</li>
					</ul>
					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/community_safety/index.cfm">Community Safety</a>
					<ul style="display: none;">
						<li><a href="?/disaster_services/index.cfm">Disaster Services</a></li>

						<li><a href="?/emergency_services/index.cfm">Emergency Services</a></li>
						<li><a href="?/municipal_enforcement/index.cfm">Municipal Enforcement</a></li>
						<li class="expandable lastExpandable"><div class="hitarea expandable-hitarea lastExpandable-hitarea"></div><a href="?/rcmp/index.cfm">Royal Canadian Mounted Police</a>
						<ul style="display: none;">
							<li><a title="Community Partnership Programs" href="?/rcmp/community_partnership_programs.cfm">Community Partnership Programs</a></li>
							<li class="last"><a title="Traffic Services" href="?/rcmp/traffic_services.cfm">Traffic Services</a></li>

						</ul>
						</li>
					</ul>
					</li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/community_services/index.cfm">Community Services</a>
					<ul style="display: none;">
						<li><a href="?/directories/community_directory/index.cfm">Community Directory</a></li>

						<li class="last"><a href="?/calendars/index.cfm">Community Calendar</a></li>

					</ul>
					</li>
					<li><a href="?/engineering/index.cfm">Engineering Services </a></li>
					<li><a href="?/finance/index.cfm">Finance</a></li>
					<li><a href="?/gis/index.cfm">Maps (GIS)</a></li>

					<li><a href="?/parks/parks_recreation.cfm">Parks &amp; Recreation</a></li>

					<li><a href="?/public_works/index.cfm">Public Works</a></li>
					<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="?/recycling_waste/index.cfm">Recycling, Waste &amp; Composting</a>
					<ul style="display: none;">
						<li class="last"><a href="?/environmental_services/index.cfm">Environmental Services </a></li>

					</ul>
					</li>

					<li><a href="?/social_planning/index.cfm">Social Planning</a></li>
					<li><a href="?/taxation/index.cfm">Taxation</a></li>
					<li><a href="?/transit/index.cfm">Transit</a></li>
					<li class="last"><a href="?/utilities/index.cfm">Water &amp; Sewer (Utilities)</a></li>

				</ul>
			</li>
			-->
		</ul>
	</div>
	<div id="sidetreecontrol"> <a href="?#">Collapse All</a> | <a href="?#">Expand All</a> </div>
</div>