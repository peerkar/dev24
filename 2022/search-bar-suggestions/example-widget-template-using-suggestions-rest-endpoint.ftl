<style>
	.devbridge-autocomplete {
			background: #fff;
			border: none;
			box-shadow: 0 1px 10px -1px rgba(109, 109, 109, 0.3);
			max-height: none!important;
			overflow: auto;
			padding: 25px;
	}

	.devbridge-autocomplete .autocomplete-group {
			font-weight: bold;
			margin: 0;
			padding: 15px 0 5px 0;
	}

	.devbridge-autocomplete .autocomplete-group:first-child {
			padding-top: 0;
	}

	.devbridge-autocomplete .autocomplete-group .type {
			font-weight: bold;
			text-transform: uppercase;
	}

	.devbridge-autocomplete .autocomplete-group .more {
			float: right;
			margin-right: 5px;
	}

	.devbridge-autocomplete .autocomplete-group .show-all {
			padding: 5px;
	}

	.devbridge-autocomplete .autocomplete-group .show-all::after {
			content: "\00BB";
			margin-left: 5px;
	}

	.devbridge-autocomplete .autocomplete-suggestion {
			margin: 0 0 5px 0;
			padding: 5px;
			white-space: normal;
	}

	.devbridge-autocomplete .autocomplete-suggestion:last-child {
			margin: 0;
	}

	.devbridge-autocomplete .autocomplete-suggestion .title {
			overflow-x: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
	}

	.devbridge-autocomplete .autocomplete-suggestion .title,
	.devbridge-autocomplete .autocomplete-suggestion .summary {
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
	}
</style>

<#assign destination = "/search" />

<#assign searchInputId = namespace + stringUtil.randomId() />

<#if searchBarPortletDisplayContext.getDestinationFriendlyURL()?has_content>
	<#assign destination = searchBarPortletDisplayContext.getDestinationFriendlyURL() />
</#if>

<@liferay_aui.fieldset cssClass="search-bar">
	<@liferay_aui.input
		cssClass="search-bar-empty-search-input"
		name="emptySearchEnabled"
		type="hidden"
		value=searchBarPortletDisplayContext.isEmptySearchEnabled()
	/>

	<div class="input-group ${searchBarPortletDisplayContext.isLetTheUserChooseTheSearchScope()?then("search-bar-scope","search-bar-simple")}">
		<#if searchBarPortletDisplayContext.isLetTheUserChooseTheSearchScope()>
			<div class="input-group-item input-group-item-shrink input-group-prepend">
				<button aria-label="${languageUtil.get(locale, "submit")}" class="btn btn-secondary" type="submit">
					<@clay.icon symbol="search" />
				</button>
			</div>

			<@liferay_aui.select
				cssClass="search-bar-scope-select"
				label=""
				name=htmlUtil.escape(searchBarPortletDisplayContext.getScopeParameterName())
				title="scope"
				useNamespace=false
				wrapperCssClass="input-group-item input-group-item-shrink input-group-prepend search-bar-search-select-wrapper"
			>
				<@liferay_aui.option
				label="this-site"
				selected=searchBarPortletDisplayContext.isSelectedCurrentSiteSearchScope()
				value=searchBarPortletDisplayContext.getCurrentSiteSearchScopeParameterString()
				/>

				<#if searchBarPortletDisplayContext.isAvailableEverythingSearchScope()>
					<@liferay_aui.option
						label="everything"
						selected=searchBarPortletDisplayContext.isSelectedEverythingSearchScope()
						value=searchBarPortletDisplayContext.getEverythingSearchScopeParameterString()
					/>
				</#if>
			</@>

			<#assign data = {
				"test-id": "searchInput"
			} />

			<@liferay_aui.input
				autoFocus=true
				autocomplete="off"
				cssClass="search-bar-keywords-input"
				data=data
				id=searchInputId
				label=""
				name=htmlUtil.escape(searchBarPortletDisplayContext.getKeywordsParameterName())
				placeholder=searchBarPortletDisplayContext.getInputPlaceholder()
				title=languageUtil.get(locale, "search")
				type="text"
				useNamespace=false
				value=htmlUtil.escape(searchBarPortletDisplayContext.getKeywords())
				wrapperCssClass="input-group-item input-group-append search-bar-keywords-input-wrapper"
			/>
		<#else>
			<div class="input-group-item search-bar-keywords-input-wrapper">
				<input
					autoFocus=true
					autocomplete="off"
					class="form-control input-group-inset input-group-inset-after search-bar-keywords-input"
					data-qa-id="searchInput"
					id=${searchInputId}
					name="${htmlUtil.escape(searchBarPortletDisplayContext.getKeywordsParameterName())}"
					placeholder="${searchBarPortletDisplayContext.getInputPlaceholder()}"
					title="${languageUtil.get(locale, "search")}"
					type="text"
					value="${htmlUtil.escape(searchBarPortletDisplayContext.getKeywords())}"
				/>

				<div class="input-group-inset-item input-group-inset-item-after">
					<button aria-label="${languageUtil.get(locale, "submit")}" class="btn btn-unstyled" type="submit">
						<@clay.icon symbol="search" />
					</button>
				</div>

				<@liferay_aui.input
					name=htmlUtil.escape(searchBarPortletDisplayContext.getScopeParameterName())
					type="hidden"
					value=searchBarPortletDisplayContext.getScopeParameterValue()
				/>
			</div>
		</#if>
	</div>
</@>

<#assign searchBarPortletInstanceConfiguration = searchBarPortletDisplayContext.getSearchBarPortletInstanceConfiguration() />

<#if searchBarPortletInstanceConfiguration.enableSuggestions() >

	<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.devbridge-autocomplete/1.4.11/jquery.autocomplete.min.js" integrity="sha512-uxCwHf1pRwBJvURAMD/Gg0Kz2F2BymQyXDlTqnayuRyBFE7cisFCh2dSb1HIumZCRHuZikgeqXm8ruUoaxk5tA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

	<script type="text/javascript">

		Liferay.on('allPortletsReady', function(event) {

			const inputElement = $('#${searchInputId}');

			const initAutocomplete = () => {

				$(inputElement).devbridgeAutocomplete({
					ajaxSettings: {
						contentType: 'application/json',
						data: JSON.stringify([${searchBarPortletInstanceConfiguration.suggestionsContributorConfigurations()?join(",")}]),
						headers: {
							'Accept-Language': themeDisplay.getBCP47LanguageId(),
							'Content-type': 'application/json',
							'p_auth': Liferay.authToken
						},
						type : 'POST'
					},	        
					containerClass: 'devbridge-autocomplete',
					dataType: 'json',
					deferRequestBy: 50,
					formatResult: function(suggestion, currentValue) {
						return suggestion.value;
					},
					groupBy: 'displayGroupName',
					minChars: ${searchBarPortletInstanceConfiguration.suggestionsDisplayThreshold()},
					noCache: false,
					noSuggestionNotice: '<@liferay_ui["message"] key="there-are-no-suggestions" />',
					onSelect: function(item) {
						if (item.data && item.data.url) {
							location.href = item.data.url;
						}
					},
					paramName: 'search',
					preserveInput: true,
					preventBadQueries: false,
					serviceUrl: function(currentValue) {
								let serviceURL = new URL("${searchBarPortletDisplayContext.getSuggestionsURL()}", Liferay.ThemeDisplay.getPortalURL());

								serviceURL.searchParams.append("currentURL", window.location.href);
								serviceURL.searchParams.append("destinationFriendlyURL", "${destination}");
								serviceURL.searchParams.append("groupId", themeDisplay.getScopeGroupId());
								serviceURL.searchParams.append("plid", themeDisplay.getPlid());
								serviceURL.searchParams.append("scope", "${searchBarPortletDisplayContext.getScopeParameterValue()}");
								serviceURL.searchParams.append("search", currentValue);

								return serviceURL;	    
					},				
					showNoSuggestionNotice: true,
					transformResult: function(response) {

						let transformedResults = [] 

						if (response) {

							transformedResults = $.map(response.items, function(group) {

								let displayGroupName = group.displayGroupName;
								
								return $.map(group.suggestions, function(item) {

									let url = item.attributes.assetURL;

									return {
										value: '<div title="' + item.text + '" class="title">' +
													'<a href="' + url + '">' + item.text + '</a>' +
												'</div>' +
												'<div class="summary">' + item.attributes.assetSearchSummary + '</div>', 
										data: {
											text: item.text,
											displayGroupName: displayGroupName,
											url: url
										}
									};
								});
							});
							transformedResults.sort(sortByType);
						}
						return {
							suggestions: transformedResults
						};
				  },
					triggerSelectOnValidInput: false,
					type: "POST"		
				});
			}

			const sortByType = function(A, B) {
				return ((A.data.type == B.data.type) ? 0 : ((A.data.type > B.data.type) ? 1 : -1 ));
			}

			initAutocomplete();
		});
	</script>
</#if>