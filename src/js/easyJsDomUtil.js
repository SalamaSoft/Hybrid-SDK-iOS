/**
The MIT License (MIT)

Created by XingGu Liu
Copyright (c) 2012 Salama Soft

http://www.salama.com.cn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**
 * This file works with JQuery(>=1.6) or jqMobi(>=1.11)
 * It's easy to map Xml to dom node or reverse by using functions below.
 */
(function( window, undefined ) {
	var easyJsDomUtil = new EasyJsDomUtil();
	
	function EasyJsDomUtil() {
		var RETURN_LINE_STR = '\r\n';

		var ATTR_NAME_RELOAD_SELECT = "reloadSelect";

		var ATTR_NAME_RELOAD_RADIO = "reloadRadio";
		
		/************** handle mapping *****************/
		
		/*
		 * Load xml to Dom Node.(Xml in format of List Data, eg.:<List><TestData><item1>xxx</item1></TestData><TestData><item1>xxx</item1></TestData>...</List>)
		 * @param args{
		 *	dataListXml: xml of data list,
		 * 	dataXmlNodeName: xml node name of data in list,
		 *	dataListDomNode: dom node which corresponds to root node of xml,
		 *  dataDomNodeCopy: copy of dom node which corresponds to data node of xml,
		 * 	domNodeAttrName: attribute name to indicating which dom node should be deal,
		 * 	dataNodeDidLoadFunc: function(domNode, index, length). It'll be invoked  when one node of data of xml is loaded.
		 * }
		 */
		this.loadListDataXmlToDomNode = function (args) {
		    if(args.dataListXml.length == 0) {
		        return;
		    }
		
			var xmlRootNode;
			if(typeof args.dataListXml == "string") {
				var xmlDoc = myParseXML(args.dataListXml);
				xmlRootNode = xmlDoc.childNodes[0];
			} else {
				xmlRootNode = args.dataListXml;
			}
			var xmlRowNodes = $(xmlRootNode).find(args.dataXmlNodeName);
		    
		    var tempNode;
		    var length = xmlRowNodes.length;
		    for(var i = 0; i < length; i++) {
		    		tempNode = $(args.dataDomNodeCopy).clone();
		        $(args.dataListDomNode).append(tempNode);
		        
		        //set value from xml
		        setDataXmlNode(tempNode[0], 0, args.domNodeAttrName, xmlRowNodes[i], false);
		        
		        //did load one data node
		        if(args.dataNodeDidLoadFunc != null && args.dataNodeDidLoadFunc != undefined) {
		        		args.dataNodeDidLoadFunc(tempNode[0], i, length);
		        }
		    }
		}
		
		/**
		 * 所有含有指定Attribute的Dom Node映射为Xml
		 * @param dataAttributeName: String 属性名
		 */
		this.mappingDomToDataXml = function (dataAttributeName) 
		{
			var domNodes = $('[' + dataAttributeName + ']');
			if(domNodes.length > 0) {
				return getDataXml(domNodes[0], 0, dataAttributeName);
			} else {
				return '';
			}
		};

		/**
		 * 指定的Dom Node映射为Xml
		 * @param domNode
		 * @param dataAttributeName: String 属性名
		 */
		this.mappingDomNodeToDataXml = function (domNode, dataAttributeName) 
		{
			return getDataXml(domNode, 0, dataAttributeName);
		};


		/**
		 * dataAttributeName: String 属性名
		 * dataXml: String 数据对象对应的XML
		 */
		/*
		this.mappingDataXmlToDom = function (dataAttributeName, dataXml) 
		{
			var domNodes = $('[' + dataAttributeName + ']');
			if(domNodes.length > 0) {
				setDataXml(domNodes[0], 0, dataAttributeName, dataXml);
			}
		};
		*/

		/**
		 * 映射Xml至Dom Node
		 * @param dataAttributeName String 属性名
		 * @param dataXmlNode String 数据对象对应的XML节点
		 * @param isAutoCloneListElement boolean 是否自动添加列表下的元素
		 */
		this.mappingDataXmlNodeToDom = function (dataAttributeName, dataXmlNode, isAutoCloneListElement) 
		{
			var domNodes = $('[' + dataAttributeName + ']');
			if(domNodes.length > 0) {
				setDataXmlNode(domNodes[0], 0, dataAttributeName, dataXmlNode, isAutoCloneListElement);
			}
		};

		/**
		 * 映射Xml至Dom Node
		 * @param domNode 指定的Dom Node
		 * @param dataAttributeName String 属性名
		 * @param dataXmlNode String 数据对象对应的XML节点
		 * @param isAutoCloneListElement boolean 是否自动添加列表下的元素
		 */
		this.mappingDataXmlNodeToDomNode = function(domNode, attributeName, dataXmlNode, isAutoCloneListElement) {
			setDataXmlNode(domNode, 0, attributeName, dataXmlNode, isAutoCloneListElement);
		};
		/**
		 * dataAttributeName: String 属性名
		 * simpleResultXml: String ajax取得的SimpleResult对象对应的XML
		 */
		this.mappingSimpleResultXmlToDom = function (dataAttributeName, simpleResultXml, isAutoCloneListElement) 
		{
			var domNodes = $('[' + dataAttributeName + ']');
			if(domNodes.length > 0) {
				var dataXmlNode = getNodeFromXml(simpleResultXml, 'Result');
				setDataXmlNode(domNodes[0], 0, dataAttributeName, dataXmlNode, isAutoCloneListElement);
			}
		};
		
		this.getNodeFromSimpleResultXml = function (simpleResultXml, nodeName) {
			return getNodeFromXml(simpleResultXml, nodeName);
		};

		this.getNodeFromSimpleResultXmlDoc = function (simpleResultXmlDoc, nodeName) {
			return getChildNodeByName(simpleResultXmlDoc, nodeName);
		};
		
		this.cloneRows = function (rowId, cloneCount) {
			//Clone the detail rows
			var row0 = $('#' + rowId + '');
			var rowTmp = row0;
            var i = 0;
			
			if($(row0).after != undefined) {
                var prevRow = row0;
                for(i = 0; i < cloneCount; i++) {
                    rowTmp = $(row0).clone(true);

                    prevRow.after(rowTmp);
                    prevRow = rowTmp;
                }
			} else {
                var parentNode = row0.parentNode;
			    
                for(i = 0; i < cloneCount; i++) {
                    rowTmp = $(row0).clone(true);

                    $(parentNode).append(rowTmp);
                }
			}
			
		};
		
		this.getDomNodeValue = function(domNode) {
			return GetDomNodeValue(domNode);
		};
		
		/*************************************************************/
		/***************  handle select and radio ********************/

		this.reloadAllSelectAndRadioFromResultXmlNode = function (dataXmlNode) {
			if(typeof dataXmlNode == "string") {
				dataXmlNode = myParseXML(dataXmlNode);
			}
			
			var valueLabelListNodes = $(dataXmlNode).find("ValueLabelList");
			var valueLabelListNode = null;
			var valueLabelListName;
			var valueLabelsNode;
			var valueLabelNode;
			var nodeTmp;

			var valueArray = null;
			var labelArray = null;

			var selectNodes = null;
			var domSelect;
			var radioGroupNodes = null;
			var domRadioGroup;

			var i, k, m, valueIndex, labelIndex;
			for(i = 0; i < valueLabelListNodes.length; i++) {
				valueLabelListNode = valueLabelListNodes[i];

				valueLabelListName = null;
				valueLabelsNode = null;
				for(k = 0; k < valueLabelListNode.childNodes.length; k++) {
					nodeTmp = valueLabelListNode.childNodes[k];
					if(isStrEqualIgnoreCase(nodeTmp.nodeName, "name")) {
						valueLabelListName = getXmlNodeTextValue(nodeTmp);
					} else if (isStrEqualIgnoreCase(nodeTmp.nodeName, "valueLabels")) {
						valueLabelsNode = nodeTmp;
					}
					
					if(valueLabelListName != null && valueLabelsNode != null) {
						break;
					}
				}
				
				if(valueLabelListName == null || valueLabelsNode == null) {
					continue;
				}
				
				selectNodes = $('[' + ATTR_NAME_RELOAD_SELECT + '="' + valueLabelListName + '"' + ']');
				
				radioGroupNodes = $('[' + ATTR_NAME_RELOAD_RADIO + '="' + valueLabelListName + '"' + ']');

				if(selectNodes.length == 0 && radioGroupNodes.length == 0) {
					continue;
				}
				
				//Get the value label array
				valueArray = new Array();
				labelArray = new Array();
				valueIndex = 0;
				labelIndex = 0;
				for(k = 0; k < valueLabelsNode.childNodes.length; k++) {
					valueLabelNode = valueLabelsNode.childNodes[k];
					
					for(m = 0; m < valueLabelNode.childNodes.length; m++) {
						nodeTmp = valueLabelNode.childNodes[m];
						if(isStrEqualIgnoreCase(nodeTmp.nodeName, "value")) {
							valueArray[valueIndex++] = getXmlNodeTextValue(nodeTmp);
						} else if (isStrEqualIgnoreCase(nodeTmp.nodeName, "label")) {
							labelArray[labelIndex++] = getXmlNodeTextValue(nodeTmp);
						}
					}
				}
				
				//load dom select
				for(k = 0; k < selectNodes.length; k++) {
					domSelect = selectNodes[k];
					reloadOneDomSelect(domSelect, valueArray, labelArray);
				}
				
				//load dom radio group
				for(k = 0; k < radioGroupNodes.length; k++) {
					domRadioGroup = radioGroupNodes[k];
					reloadOneDomRadio(domRadioGroup, valueArray, labelArray);
				}
			}
		};
		
		this.reloadAllSelectByName = function (name, valueArray, labelArray) {
			var controls = document.getElementsByName(name);
			
			for(var i = 0; i < controls.length; i++) {
				reloadOneDomSelect(controls[i], valueArray, labelArray);
			}
		};
		
		this.reloadDomSelect = function (domSelect, valueArray, labelArray) {
			reloadOneDomSelect(domSelect, valueArray, labelArray);
		};

		function reloadOneDomRadio(domRadioGroup, valueArray, labelArray) {
		    if($(domRadioGroup).after == undefined) {
		        alert('$().after() must be be supported.');
		        return;
		    }

			var nodeTmp;
			var nodeNameTmp = "";
			var i, k, radioNodesCnt;
			var index, index1, index2;
			
			var radioNodesArray = new Array();
			
			var childNodes = $(domRadioGroup).children();
			var domRadioNodes = $(domRadioGroup).find('input[type="radio"]');
			
			if(domRadioNodes.length == 0) {
				return;
			} else if (domRadioNodes.length == 1) {
				radioNodesCnt = 1;
			} else {
				for(i = 0; i < childNodes.length; i++) {
					if(childNodes[i].nodeName)
					if(isStrEqualIgnoreCase(nodeNameTmp, childNodes[i].nodeName)) {
						//Find the loop cnt
						radioNodesCnt = i;
					}
				}
			}
			
			if(childNodes.length == 0) {
				return;
			} else if(childNodes.length == 1) {
				radioNodesCnt = 1;
			} else {
				index1 = -1;
				index2 = 1;
				for(i = 0; i < childNodes.length; i++) {
					nodeTmp = childNodes[i];
					if(nodeTmp.tagName.toLowerCase() == "input"
						&& nodeTmp.type.toLowerCase() == "radio") {
						if(index1 < 0) {
							index1 = i;
						} else {
							index2 = i;
							break;
						}
					}
				}
				
				radioNodesCnt = index2 - index1;
			}

			//Copy nodes to array
			index = 0;
			for(k = 0; k < radioNodesCnt; k++) {
				radioNodesArray[index++] = $(childNodes[k]).clone(true);
			}
			
			//Remove all nodes except 1st
			var length = domRadioGroup.childNodes.length;
			for(i = 0; i < length; i++) {
				$(domRadioGroup.childNodes[0]).remove();
			}
			
			//Append
			for(i = 0; i < valueArray.length; i++) {
				for(index = 0; index < radioNodesArray.length; index++) {
					$(domRadioGroup).append($(radioNodesArray[index]).clone(true));
				}
			}
			
			//set value and label
			domRadioNodes = $(domRadioGroup).find('input[type="radio"]');
			
			for(i = 0; i < domRadioNodes.length; i++) {
				$(domRadioNodes[i]).val(valueArray[i]);
				
				if(radioNodesCnt == 1) {
					$(domRadioNodes[i]).after(labelArray[i]);
				} else {
					nodeTmp = getNextSibling($(domRadioNodes[i]));
					try{
						$(nodeTmp).text(labelArray[i]);
					} catch(e) {
						try{
							$(nodeTmp).val(labelArray[i]);
						} catch(e) {
							$(domRadioNodes[i]).after(labelArray[i]);
						}
					}
					
				}
			}
			
		}

		function reloadOneDomSelect(domSelect, valueArray, labelArray) {
			var k;
			var len = domSelect.options.length;
			
			for(k = 0; k < len; k++) {
				domSelect.remove(0);
			}
			
			len = valueArray.length;
			var option;
			for(k = 0; k < len; k++) {
				option = document.createElement('option');
				option.value = valueArray[k];
				option.text = labelArray[k];
				
				if(isMSIE()){
					domSelect.add(option);
				} else {
					domSelect.add(option, null);
				}
			}
		}

		/*******************************************************************************/
		this.getChildNodeFromXml = function (simpleResultXml, nodeName) {
			return getNodeFromXml(simpleResultXml, nodeName);
		};
		
		function getNodeFromXml(simpleResultXml, nodeName) {
			var simpleResultXmlDoc = null;
			if(typeof simpleResultXml == "string") {
				simpleResultXmlDoc = myParseXML(simpleResultXml);
			} else {
				simpleResultXmlDoc = simpleResultXml;
			}
			
			return getChildNodeByName(simpleResultXmlDoc.firstChild, nodeName);
		}
		
		function getChildNodeByName(xmlNode, nodeName) {
			for(var i = 0; i < xmlNode.childNodes.length; i++) {
				if(isStrEqualIgnoreCase(xmlNode.childNodes[i].nodeName, nodeName)) {
					return xmlNode.childNodes[i];
				}
			}
			
			return null;
		}
		
//		/**
//		 * dataAttributeName: String 属性名
//		 * simpleResultXmlNode: String ajax取得的SimpleResult对象对应的XML的根节点
//		 */
//		this.mappingSimpleResultNodeToDom = function (dataAttributeName, simpleResultXmlNode) 
//		{
//			var domNodes = $('[' + dataAttributeName + ']');
//			if(domNodes.length > 0) {
//				setDataXml(domNodes[0], 0, dataAttributeName, simpleResultXmlNode);
//			}
//		};

		/**
		 * callBackWhenForwardNode(node, depth)
		 * callBackWhenBackwardNode(node, depth)
		 * callBackWhenVisitLeafNode(node, depth)
		 * 
		 * return: void
		 */
		/* traverseDomNode() has already ignored text node
		function traverseDomNodeIgnoreTextNode(domNode, depth,
				callBackWhenForwardNode,
				callBackWhenBackwardNode,
				callBackWhenVisitLeafNode) {
			
				traverseDomNode (domNode, depth,
					function(nodeTmp, depthTmp) {
						//forward
		            	if(nodeTmp.nodeType != 3) {
		            		if(nodeTmp.childNodes.length == 1) {
	            				if(nodeTmp.childNodes[0].nodeType == 3) {
	            					callBackWhenVisitLeafNode(nodeTmp, depthTmp);
	            					return;
	            				}
		            		}
		            		callBackWhenForwardNode(nodeTmp, depthTmp);
		            	}
					},
					function(nodeTmp, depthTmp) {
						//backward
						callBackWhenBackwardNode(nodeTmp, depthTmp);
					},
					function(nodeTmp, depthTmp) {
						//visit leaf
		            	if(nodeTmp.nodeType != 3) {
		            		callBackWhenVisitLeafNode(nodeTmp, depthTmp);
		            	}
					}
			);			
		}
		*/
		function traverseDomNode(domNode, depth,
				callBackWhenForwardNode,
				callBackWhenBackwardNode,
				callBackWhenVisitLeafNode) {

			var nodeTmp = domNode;
			var depthTmp = depth;
			var backwardFlg = false;
			var nodeNextSiblingTmp = null;
			var nodeChildTmp = null;

			if(domNode == null) {
				return;
			}
			
			while (nodeTmp != null)
		    {
				nodeChildTmp = getFirstChildNotTextNode(nodeTmp);
		        if (nodeChildTmp != null)
		        {
		        	//Debug
		            if (backwardFlg)
		            {
		                if (depthTmp < depth) break;

		                //callBack
		                callBackWhenBackwardNode(nodeTmp, depthTmp);

		                if (depthTmp <= depth) break;
		                
		                nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeTmp); 
		                if (nodeNextSiblingTmp == null)
		                {
		                    nodeTmp = nodeTmp.parentNode;
		                    backwardFlg = true;
		                    depthTmp--;
		                }
		                else
		                {
		                	nodeTmp = nodeNextSiblingTmp;
		                    backwardFlg = false;
		                }
		            }
		            else
		            {
		            	//callback 
		            	callBackWhenForwardNode(nodeTmp, depthTmp);
		            	
		                nodeTmp = nodeChildTmp;
		                depthTmp++;
		            }
		        }
		        else
		        {
		            //leaf node
		        	//callback
		        	callBackWhenVisitLeafNode(nodeTmp, depthTmp);

	                nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeTmp); 
		            if (nodeNextSiblingTmp == null)
		            {
		                nodeTmp = nodeTmp.parentNode;
		                backwardFlg = true;
		                depthTmp--;
		            }
		            else
		            {
		                nodeTmp = nodeNextSiblingTmp;
		            }
		        }
		    }//while
			
		}
		
		/**
		 * callBackWhenForwardNode(node, depth)
		 * callBackWhenBackwardNode(node, depth)
		 * callBackWhenVisitLeafNode(node, depth)
		 * return CommonNode
		 */
		function traverseDomNodeFilteredByAttributeName(
				domNode, depth, attributeName,
				callBackWhenForwardNode,
				callBackWhenBackwardNode,
				callBackWhenVisitLeafNode
				) {
			traverseDomNode(domNode, depth,
					function(nodeTmp, depthTmp) {
						//forward
		                if($(nodeTmp).attr(attributeName) != undefined) {
		                	if(getFirstChildByAttributeName(nodeTmp, attributeName) == null) {
					        	callBackWhenVisitLeafNode(nodeTmp, depthTmp);
		                	} else {
				            	callBackWhenForwardNode(nodeTmp, depthTmp);
		                	}
		                }
					},
					function(nodeTmp, depthTmp) {
						//backward
		                if($(nodeTmp).attr(attributeName) != undefined) {
		                	if(getFirstChildByAttributeName(nodeTmp, attributeName) != null) {
				                callBackWhenBackwardNode(nodeTmp, depthTmp);
		                	}
		                }
					},
					function(nodeTmp, depthTmp) {
						//visit leaf
		                if($(nodeTmp).attr(attributeName) != undefined) {
				        	callBackWhenVisitLeafNode(nodeTmp, depthTmp);
		                }
					}
			);			
		}

		function getDataXml(domNode, depth, attributeName)
		{
			var nodeXml = '';

			traverseDomNodeFilteredByAttributeName(
					domNode, depth, attributeName,
					function(nodeTmp, depthTmp) {
						//forward
		            	nodeXml += GetNodeBeginXml(nodeTmp, depthTmp, attributeName);
		            	nodeXml += RETURN_LINE_STR;
					},
					function(nodeTmp, depthTmp) {
						//backward
		                nodeXml += GetNodeEndXml(nodeTmp, depthTmp, attributeName);
		                nodeXml += RETURN_LINE_STR;
					},
					function(nodeTmp, depthTmp) {
						//visit leaf
			        	nodeXml += GetNodeBeginXml(nodeTmp, depthTmp, attributeName);
			        	
			        	nodeXml += encodeXmlContent(GetDomNodeValue(nodeTmp));
			        	nodeXml += GetNodeEndXml(nodeTmp, 0, attributeName);
			        	nodeXml += RETURN_LINE_STR;
					}
					);
			
			return nodeXml;
		}
		
		function autoCloneListElement(domNode, attributeName, dataXmlNode) {
			var domNodeTmps = $(domNode).find('[' + attributeName + '][autoCloneListElement]');
			if(domNodeTmps.length == 0) {
				return;
			}
			
			//reset all handled status
			var autoCloneHandledAttr = 'autoCloneListElementHandled' + (new Date()).getTime();
			$(domNodeTmps).each(function () {
				$(this).attr(autoCloneHandledAttr, 'false');
			});
			
			autoCloneListElementImp(domNode, attributeName, dataXmlNode, autoCloneHandledAttr);
			
			$(domNode).removeAttr(autoCloneHandledAttr);
			$($(domNode).find('[' + autoCloneHandledAttr + ']')).each(function() {
				$(this).removeAttr(autoCloneHandledAttr);
			});
		}

		function autoCloneListElementImp(domNode, attributeName, dataXmlNode, autoCloneHandledAttrName){
			if($(domNode).attr(autoCloneHandledAttrName) == 'true') {
				return;
			} else {
				$(domNode).attr(autoCloneHandledAttrName, 'true');
			}

			//var childrenAutoListNodes = new Array();
			var i, j;
			var index = 0;
			var index2 = 0;
			var xmlNodeTmp = dataXmlNode;
			var xmlNodeTmp2 = null;
			var xmlNodeListTmp = null;
			var domNodeNotHandledParents = null;
			var domNodeParents = null;
			var attrVal = '';
			var listSize = 0;
			var nodeTmp2 = null;
			var domNodeTmp2;
			var domLen = 0;
			var domNodeTmp3 = null;
			var domNodeTmp4 = null;
			var index3 = 0;
			var domNodePrevTmp = null;
			
			//var domNodeTmps = $(domNode).find('[' + attributeName + '][autoCloneListElement]['+ autoCloneHandledAttrName +'="false"]');
			var domNodeTmps = $(domNode).find('[' + attributeName + '][autoCloneListElement]');
			if(domNodeTmps.length == 0) {
				return;
			}
			for(i = 0; i < domNodeTmps.length; i++) {
				domNodeTmp2 = domNodeTmps[i];
				//IE8 not support .parentNode
				//if(domNodeTmp2.parentNode == null || domNodeTmp2.parentNode == undefined) {
				if($(domNodeTmp2).parents().length == 0) {
					continue;
				}
				if($(domNodeTmp2).attr(autoCloneHandledAttrName) == 'true') {
					continue;
				}
				
				domNodeNotHandledParents = $(domNodeTmp2).parents('[' + attributeName + ']['+ autoCloneHandledAttrName +'="false"]');
				
				if(domNodeNotHandledParents.length == 0) {
					//Sync the xml data node
					domNodeParents = $(domNodeTmp2).parents('[' + attributeName + ']');
					
					for (index = 0; index < domNodeParents.length; index++) {
						if($(domNodeParents[index]).attr(autoCloneHandledAttrName) == 'true') {
							index2 = index - 1;
							break;
						}
					}
					
					xmlNodeTmp2 = xmlNodeTmp;
					for(index = index2; index >= 0; index--) {
						attrVal = $(domNodeParents[index]).attr(attributeName);
						attrVal = attrVal.charAt(0).toLowerCase() + attrVal.substring(1);
						nodeTmp2 = $(xmlNodeTmp2).children(attrVal);

						if(nodeTmp2.length == 0) {
							attrVal = attrVal.charAt(0).toUpperCase() + attrVal.substring(1);
							nodeTmp2 = $(xmlNodeTmp2).children(attrVal);
						} 
						
						//now, sync the xmlNodeTmp to the parent of current list element
						xmlNodeTmp2 = nodeTmp2[0];
					}//for
					
					//Clone the nodes
					listSize = ($(xmlNodeTmp2).children()).length;
					
					attrVal = $(domNodeTmp2).attr(attributeName);
					domNodeTmp3 = $(domNodeTmp2.parentNode).children('[' + attributeName + '="' + attrVal + '"]');
					domLen = domNodeTmp3.length;
					
					//$(domNodeTmp3[0]).attr('display', 'normal');
					
					if(domLen > listSize) {
						for(index3 = domLen - 1; index3 >= listSize; index3--) {
							if(index3 == 0) {
								//keep the [0]
								//$(domNodeTmp3[index3]).attr('display', 'none');
							} else {
								$(domNodeTmp3[index3]).remove();
							}
						}
					} else if (domLen < listSize) {
					    /* modify to adapt jqMobi
						domNodePrevTmp = domNodeTmp3[domLen-1];
						for(index3 = domLen; index3 < listSize; index3++) {
							domNodeTmp4 = $(domNodePrevTmp).clone(true);
							$(domNodePrevTmp).after(domNodeTmp4);
							domNodePrevTmp = domNodeTmp4;
						}
						*/
                        domNodePrevTmp = domNodeTmp3[domLen-1];
						var parentNodeTmp = domNodeTmp3[0].parentNode;
                        for(index3 = domLen; index3 < listSize; index3++) {
                            domNodeTmp4 = $(domNodePrevTmp).clone(true);
                            $(parentNodeTmp).append(domNodeTmp4);
                        }
					}

					if(listSize > 0) {
						//loop the cloned nodes
						domNodeTmp3 = $(domNodeTmp2.parentNode).children('[' + attributeName + '="' + attrVal + '"]');
						domLen = domNodeTmp3.length;
						xmlNodeListTmp = $(xmlNodeTmp2).children();
						for(j = 0; j < domNodeTmp3.length; j++)
						{
							autoCloneListElementImp(domNodeTmp3[j], attributeName, xmlNodeListTmp[j], autoCloneHandledAttrName);
						}
					} else {
						//remove all the list node of children to retain size 1
						removeListElementToSize1(domNodeTmp2.parentNode, 0, attributeName);
					}
					
				}//if
			}//for
		}
	
		function removeListElementToSize1(domNode, depth, attributeName) {
				var attributeValue = null;
				var autoSizeAttr = null;
				var i = 0;
				var domLen = 0;
				var domNodeTmp = null;
				
				function removeListNodeToSize1(nodeTmp, depthTmp){
					autoSizeAttr = $(nodeTmp).attr("autoCloneListElement");
					
					if(autoSizeAttr == undefined) {
						return;
					}

					attributeValue = $(nodeTmp).attr(attributeName);
					domNodeTmp = $(nodeTmp.parentNode).children('[' + attributeName + '="' + attributeValue + '"]');
					domLen = domNodeTmp.length;

					for(i = domLen - 1; i >= 1; i--) {
						$(domNodeTmp[i]).remove();
					}
				}
				
				traverseDomNodeFilteredByAttributeName(
						domNode, depth, attributeName,
						function(nodeTmp, depthTmp) {
							//forward
							removeListNodeToSize1(nodeTmp, depthTmp);
						},
						function(nodeTmp, depthTmp) {
							//backward
						},
						function(nodeTmp, depthTmp) {
							//visit leaf
							removeListNodeToSize1(nodeTmp, depthTmp);
						}
						);
		}

		function autoCloneListElementToFixedSize(domNode, depth, attributeName, dataXmlNode) {
				var attributeValue = null;
				var autoSizeAttr = null;
				var autoSize = null;
				var i = 0;
				var domLen = 0;
				var domNodeTmp = null;
				var domNodeTmp2 = null;
				var domNodePrevTmp = null;
				var listSize = 0;
				
				function cloneListNode2(nodeTmp, depthTmp){
					autoSizeAttr = $(nodeTmp).attr("autoCloneListElement");
					
					if(autoSizeAttr == undefined) {
						return;
					}
					
					autoSize = Number(autoSizeAttr);
					if(!isNaN(autoSize)) {
						attributeValue = $(nodeTmp).attr(attributeName);
						domNodeTmp = $(nodeTmp.parentNode).children('[' + attributeName + '="' + attributeValue + '"]');
						domLen = domNodeTmp.length;
						listSize = autoSize;
						
						//$(domNodeTmp[0]).attr('display', 'normal');
						
						if(domLen > listSize) {
							for(i = domLen - 1; i >= listSize; i--) {
								$(domNodeTmp[i]).remove();
							}
						} else if (domLen < listSize) {
                            /* modify to adapt jqMobi
							domNodePrevTmp = domNodeTmp[domLen-1];
							for(i = domLen; i < listSize; i++) {
								domNodeTmp2 = $(domNodePrevTmp).clone(true);
								$(domNodePrevTmp).after(domNodeTmp2);
								domNodePrevTmp = domNodeTmp2;
							}
							*/
                            domNodePrevTmp = domNodeTmp[domLen-1];
                            var parentNodeTmp = domNodeTmp[0].parentNode;
                            for(i = domLen; i < listSize; i++) {
                                domNodeTmp2 = $(domNodePrevTmp).clone(true);
                                $(parentNodeTmp).append(domNodeTmp2);
                            }
						}
					}
				}
				
				traverseDomNodeFilteredByAttributeName(
						domNode, depth, attributeName,
						function(nodeTmp, depthTmp) {
							//forward
						},
						function(nodeTmp, depthTmp) {
							//backward
							cloneListNode2(nodeTmp, depthTmp);
						},
						function(nodeTmp, depthTmp) {
							//visit leaf
							cloneListNode2(nodeTmp, depthTmp);
						}
						);
		}

		function setDataXmlNode(domNode, depth, attributeName, dataXmlNode, isAutoCloneListElement) {
			var nodeXml = '';
			var domNodeArray = new Array();
			var domNodeIndexTmp = 0;

            if ((isAutoCloneListElement != undefined) && (isAutoCloneListElement == true)) {
				//clone the list elements to the size in Result Xml
				autoCloneListElement(domNode, attributeName, dataXmlNode);
				
				//clone the node which auto fixed size
				autoCloneListElementToFixedSize(domNode, depth, attributeName, dataXmlNode);
			}
			
			//prescan
			traverseDomNodeFilteredByAttributeName(
					domNode, depth, attributeName,
					function(nodeTmp, depthTmp) {
						//forward
		            	nodeXml += GetNodeBeginXml(nodeTmp, depthTmp, attributeName);
		            	nodeXml += RETURN_LINE_STR;
					},
					function(nodeTmp, depthTmp) {
						//backward
		                nodeXml += GetNodeEndXml(nodeTmp, depthTmp, attributeName);
		                nodeXml += RETURN_LINE_STR;
					},
					function(nodeTmp, depthTmp) {
						//visit leaf
			        	nodeXml += GetNodeBeginXml(nodeTmp, depthTmp, attributeName);
			        	nodeXml += '' + domNodeIndexTmp;
			        	nodeXml += GetNodeEndXml(nodeTmp, 0, attributeName);
			        	nodeXml += RETURN_LINE_STR;
			        	
			        	SetDomNodeValue(nodeTmp, "");
	            		domNodeArray[domNodeIndexTmp] = nodeTmp;
			        	domNodeIndexTmp++;
					}
					);

			//Scan the xml
			//New way , the difference is that ignoring the text node
			{
				var xmlDocFromDom = myParseXML(nodeXml);
				var nodeTmp = xmlDocFromDom.childNodes[0];
				//var nodeTmp2 = $(dataXmlNode).closest("Result")[0];
				var nodeTmp2 = dataXmlNode;

				var nodeTmp2Next = null;
				
				var depthTmp = depth;
				var backwardFlg = false;
				var nodeNameTmp = null;
				
				var nodeNextSiblingTmp = null;
				var nodeChildTmp = null;
				
			    while (nodeTmp != null)
			    {
					nodeChildTmp = getFirstChildNotTextNode(nodeTmp);
			        if (nodeChildTmp != null)
			        {
			            if (backwardFlg)
			            {
			                if (depthTmp < depth) break;

							nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeTmp);
			                if (nodeNextSiblingTmp != null)
			                {
				            	nodeNameTmp = nodeTmp.nodeName;

				            	nodeTmp = nodeNextSiblingTmp;
			                    backwardFlg = false;

				                //sync the dom xml node operation
				                //The next node of xml data maybe null 
				                if(nodeTmp.nodeName == nodeNameTmp) {
				                	//Node name are same, so these nodes is the element of a list or array
				                	nodeTmp2Next = getNextSiblingNotTextNode(nodeTmp2);
				                } else {
				                	//Find the same tag node in this depth
				                	nodeTmp2Next = findChildXmlNode(nodeTmp2.parentNode, nodeTmp.nodeName);
				                }

				                if(nodeTmp2Next != null) {
					                nodeTmp2 = nodeTmp2Next;
				                } else {
				                    backwardFlg = true;
				                }
			                }
			                else
			                {
			                	//IndexXml
			                    nodeTmp = nodeTmp.parentNode;
			                    backwardFlg = true;
			                    depthTmp--;
			                    
				                //sync the dom xml node operation
				                nodeTmp2 = nodeTmp2.parentNode;
			                }
			            } //if backward 
			            else
			            {
			            	//IndexXml
			                nodeTmp = nodeChildTmp;
			                backwardFlg = false;
			                depthTmp++;

			                //sync the dom xml node operation
			                //Find the first child whose name is same as nodeTmp
							nodeTmp2Next = null;
							nodeNextSiblingTmp = nodeTmp;
							while(true) {
								nodeTmp2Next = findChildXmlNode(nodeTmp2, nodeNextSiblingTmp.nodeName);
								if(nodeTmp2Next != null) {
									break;
								}
								
								nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeNextSiblingTmp);
								if(nodeNextSiblingTmp == null) {
									break;
								}
							}
							
							if(nodeTmp2Next != null) {
								nodeTmp2 = nodeTmp2Next;
								nodeTmp = nodeNextSiblingTmp;
							} else {
				                nodeTmp = nodeTmp.parentNode;
				                backwardFlg = true;
				                depthTmp--;
							}
							
			            } // backward
			        } // child != null
			        else
			        {
			            //leaf node
			        	//Set value to domNode *******************************************
			        	domNodeIndexTmp = getXmlNodeTextValue(nodeTmp);
			        	//nodeType == 9 is the document node
			        	if(
		        			isStrEqualIgnoreFirstCharCase(nodeTmp.nodeName, nodeTmp2.nodeName)
		        			) {
			        		if(domNodeArray[domNodeIndexTmp] != undefined) {
					        	SetDomNodeValue(domNodeArray[domNodeIndexTmp], decodeXmlContent(getXmlNodeTextValue(nodeTmp2)));
			        		}
			        	}

			        	nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeTmp);
			            if (nodeNextSiblingTmp != null)
			            {
			            	nodeNameTmp = nodeTmp.nodeName;
			            	
			            	nodeTmp = nodeNextSiblingTmp;
			                backwardFlg = false;

			                //sync the dom xml node operation
			                if(nodeTmp.nodeName == nodeNameTmp) {
			                	//Node name are same, so these nodes is the element of a list or array
			                	nodeTmp2Next = getNextSiblingNotTextNode(nodeTmp2);

				                if(nodeTmp2Next != null) {
					                nodeTmp2 = nodeTmp2Next;
				                } else {
				                    nodeTmp = nodeTmp.parentNode;
				                    backwardFlg = true;
				                    depthTmp--;
				                    
					                //sync the dom xml node operation
					                nodeTmp2 = nodeTmp2.parentNode;
								}
			                } else {
			                	//Find the same tag node in this depth
								nodeTmp2Next = null;
								nodeNextSiblingTmp = nodeTmp;
								while(true) {
									nodeTmp2Next = findChildXmlNode(nodeTmp2.parentNode, nodeNextSiblingTmp.nodeName);
									if(nodeTmp2Next != null) {
										break;
									}
									
									nodeNextSiblingTmp = getNextSiblingNotTextNode(nodeNextSiblingTmp);
									if(nodeNextSiblingTmp == null) {
										break;
									}
								}
								
								if(nodeTmp2Next != null) {
									nodeTmp = nodeNextSiblingTmp;
									nodeTmp2 = nodeTmp2Next;
								} else {
					                nodeTmp = nodeTmp.parentNode;
					                backwardFlg = true;
					                depthTmp--;
									
					                nodeTmp2 = nodeTmp2.parentNode;
								}
			                }
			            }
			            else
			            {
			                nodeTmp = nodeTmp.parentNode;
			                backwardFlg = true;
			                depthTmp--;
			                
			                //sync the dom xml node operation
			                nodeTmp2 = nodeTmp2.parentNode;
			            }
			        }
	            	
			    }//while
			}
			
			return nodeXml;
		}

		function isPropertyNameEqual(name1, name2) {
			if(name1 == name2) {
				return true;
			} else {
				var strL = "";
				var strS = "";
				
				if(name1.length > name2.length) {
					strS = "." + name2;
					strL = name1;
				} else if(name1.length < name2.length) {
					strS = "." + name1;
					strL = name2;
				} else {
					return false;
				}
				
				var index = strL.indexOf(strS);
				
				if(index < 0) {
					return false;
				} else {
					if((strL.length - index) == strS.length) {
						return true;
					} else {
						return false;
					}
				}
			}
		}
		
		function getAttributeValue(node, attributeName) {
			if(node.attributes != null) {
				if(isMSIE()){
					for(var i = 0; i < node.attributes.length; i++) {
						if(node.attributes[i].name == attributeName) {
							return node.attributes[i].value;
						}
					}
					
					return null;
				} else {
					return node.attributes[attributeName].value;
				}
			} else {
				return null;
			}
		}
		
		function containsAttribute(node, attributeName) {
			if(node.attributes != null) {
				if(isMSIE()){
					for(var i = 0; i < node.attributes.length; i++) {
						if(node.attributes[i].name == attributeName) {
							return true;
						}
					}
					
					return false;
				} else {
					if(node.attributes[attributeName] != null) {
						return true;
					} else {
						return false;
					}
				}
			} else {
				return false;
			}
		}
		
		function GetNodeBeginXml(node, depth, attributeName)
		{
			var beginXml = GetNodeDepthStr(depth) + "<" + GetNodeName(node, attributeName);

//		    for (i = 0; i < node.getAttributes().size(); i++)
//		    {
//		        beginXml += " " + GetNodeAttributeXml(node.getAttributes().get(i));
//		    }
		    beginXml += ">";

		    return beginXml;
		}

		function GetNodeName(node, attributeName) {
			return getAttributeValue(node,attributeName);
		}
		function GetDomNodeValue (node) {
			if(node.tagName.toLowerCase() == "input") {
				if(node.type.toLowerCase() == "radio")
				{
					//visit all sibling
					var nodeTmp = node;
					var radioName = node.name;
					
					while(nodeTmp != null)
					{
						if(!isXmlNodeTextType(nodeTmp)
							&& nodeTmp.tagName.toLowerCase() == "input"
							&& nodeTmp.type.toLowerCase() == "radio"
							&& nodeTmp.name == radioName
							&& nodeTmp.checked)
						{
							return nodeTmp.value;
						} 
						
						nodeTmp = getNextSibling(nodeTmp);
					}
					
					return "";
				}
				else if(node.type.toLowerCase() == "checkbox")
				{
					if(node.checked)
					{
						return "true";
					} 
					else 
					{
						return "false";
					}
				}
				else 
				{
					//return node.value;
					return $(node).val();
				}
			} else if(node.tagName.toLowerCase() == "select") {
				var selectedIndex = 0;
				if(node.selectedIndex >= 0) 
				{
					selectedIndex = node.selectedIndex; 
				}
				if (node.options.length == 0) {
					return "";
				}
				return node.options[selectedIndex].value;
			} else if(node.tagName.toLowerCase() == "textarea") {
				return $(node).val();
			} else {
				var radioChildren = $(node).find('input[type="radio"]');
				if(radioChildren.length > 0) {
					for(var i = 0; i < radioChildren.length; i++) {
						if(radioChildren[i].checked) {
							return radioChildren[i].value;
						}
					}
					return "";
				} else {
					//return node.innerText;
					return $(node).text();
				}
			}
		}
		this.setDomNodeValue = function (node, value) {
			return SetDomNodeValue(node, value);
		}
		function SetDomNodeValue(node, value) {
			if(node.tagName.toLowerCase() == "input") {
				if(node.type.toLowerCase() == "radio")
				{
					//visit all sibling
					var nodeTmp = node;
					var radioName = node.name;

					while(nodeTmp != null)
					{
						if(!isXmlNodeTextType(nodeTmp)
							&& nodeTmp.tagName.toLowerCase() == "input"
							&& nodeTmp.type.toLowerCase() == "radio"
							&& nodeTmp.name == radioName
							&& nodeTmp.value == value)
						{
							nodeTmp.checked = true;
						} 
						else 
						{
							nodeTmp.checked = false;
						}
						
						nodeTmp = getNextSibling(nodeTmp);
					}
				}
				else if(node.type.toLowerCase() == "checkbox")
				{
					if("true" == value)
					{
						node.checked = true;
					} 
					else
					{
						node.checked = false;
					}
				}
				else 
				{
					$(node).val(value);
				}
			} // if input <-
			else if(node.tagName.toLowerCase() == "select") 
			{
				var selectedIndex = node.selectedIndex;
				if(selectedIndex < 0) 
				{
					selectedIndex = 0;
				}
				for(var i = 0; i < node.options.length; i++)
				{
					if(node.options[i].value == value)
					{
						selectedIndex = i;
						break;
					}
				}
				node.selectedIndex = selectedIndex;
			} else if(node.tagName.toLowerCase() == "textarea") {
				$(node).val(value);
			} else {
				var radioChildren = $(node).find('input[type="radio"]');
				if(radioChildren.length > 0) {
					for(var i = 0; i < radioChildren.length; i++) {
						if(radioChildren[i].value == value) {
							radioChildren[i].checked = true;
						} else {
							radioChildren[i].checked = false;
						}
					}
				} else {
					//node.innerText = value;
					$(node).text(value);
				}
			}
		}

		function GetNodeEndXml(node, depth, attributeName)
		{
		    return GetNodeDepthStr(depth) + "</" + GetNodeName(node, attributeName) + ">";
		}

		function GetNodeDepthStr(depth)
		{
		    if (depth <= 0) return "";

		    var depthStr = "";
		    var i = 0; 
		    for (;i < depth; i++)
		    {
		        depthStr += "  ";
		    }

		    return depthStr;
		}

		/**************** XML ***************************/
		var MetaChars = new Array('<', '>', '&', '\'', '"' );
		var EncodeStrs = new Array("&lt;", "&gt;", "&amp;", "&apos;", "&quot;");

		this.encodeXml = function(xmlContent) {
			return encodeXmlContent(xmlContent);
		};
	
		this.decodeXml = function(xmlContent) {
			return decodeXmlContent(xmlContent);
		};

		function encodeXmlContent(content)
		{
			var encodedContent = '';
		    if(content == null) return content;

		    var i = 0;
		    var indexOfMeta = 0;
		    for (; i < content.length; i++)
		    {
		        indexOfMeta = 0;
		        for (; indexOfMeta < 5; indexOfMeta++)
		        {
		            if (content.charAt(i) == MetaChars[indexOfMeta])
		            {
		                break;
		            }
		        }

		        if (indexOfMeta < 5)
		        {
		        	encodedContent += EncodeStrs[indexOfMeta];
		        }
		        else
		        {
		        	encodedContent += content.charAt(i);
		        }
		    }

		    return encodedContent;
		}

		function decodeXmlContent(content)
		{
		    if (content == null) 
		    {
		    	return content;
		    }

		    var decodedContent = '';
		    
		    var strTmp = "";
		    var lenTmp = 0;
		    var indexOfEncodeStr = 0;
		    
		    var i = 0;
		    for (; i < content.length; i++)
		    {
		        if (content.charAt(i) == '&')
		        {
		            indexOfEncodeStr = 0;
		            for (; indexOfEncodeStr < EncodeStrs.length; indexOfEncodeStr++)
		            {
		                lenTmp = EncodeStrs[indexOfEncodeStr].length;
		                if ((i + lenTmp) <= content.length)
		                {
		                    strTmp = content.substring(i, i + lenTmp);
		                    if (strTmp == EncodeStrs[indexOfEncodeStr])
		                    {
		                        break;
		                    }
		                }
		            }

		            if (indexOfEncodeStr < EncodeStrs.length)
		            {
		            	decodedContent += MetaChars[indexOfEncodeStr];
		                i += EncodeStrs[indexOfEncodeStr].length - 1;
		            }
		            else
		            {
		            	decodedContent += content.charAt(i);
		            }
		        }
		        else
		        {
		        	decodedContent += content.charAt(i);
		        }
		    }

		    return decodedContent;
		}

		function findNextXmlNode(node, nodeName) {
			var nodeTmp = getNextSibling(node);
			
			while(nodeTmp != null) {
				if(isStrEqualIgnoreFirstCharCase(nodeTmp.nodeName, nodeName))
				{
					return nodeTmp;
				}
				
				nodeTmp = getNextSibling(nodeTmp);
			}
			
			return null;
		}
		
		function findChildXmlNode(node, nodeName) {
			var childNode = getFirstChild(node);
			
			if(childNode != null) {
				if(isStrEqualIgnoreFirstCharCase(childNode.nodeName, nodeName)) {
					return childNode;
				} else {
					return findNextXmlNode(childNode, nodeName);
				}
			} else {
				return null;
			}
		}
		
		function isXmlNodeTextType(xmlNode) {
			if(xmlNode.nodeType == 3 || xmlNode.nodeType == 8) {
				return true;
			} else {
				return false;
			}
		}
		
		function isStrEqualIgnoreCase(name1, name2) {
			if(name1.toLowerCase() == name2.toLowerCase()) {
				return true;
			} else {
				return false;
			}
		}
		
		function isStrEqualIgnoreFirstCharCase(name1, name2) {
			return isStrEqualIgnoreCase(name1, name2);
			/* In some explore xml document contents are automotical converted to UPPERCASE.
			 * so there is no case sensitive compare. 
			var strTmp1 = name1.charAt(0).toLowerCase() + name1.substring(1);
			var strTmp2 = name2.charAt(0).toLowerCase() + name2.substring(1);
			
			if(strTmp1 == strTmp2) {
				return true;
			} else {
				return false;
			}
			*/
		}
		
		this.getXmlNodeText = function (xmlNode) {
			return getXmlNodeTextValue(xmlNode);
		};
		
		function getXmlNodeTextValue(xmlNode) {
			return $(xmlNode).text();
			/*
			if(isExploreSupportWebkit()) {
				return xmlNode.textContent;
			} else {
				if(xmlNode.textContent == undefined) {
					return xmlNode.text;
				} else {
					return xmlNode.textContent;
				}
			}
			*/
		}

		function setXmlNodeTextValue(xmlNode, nodeValue) {
			$(xmlNode).text(xmlNode, nodeValue);
			/*
			if(isExploreSupportWebkit()) {
				xmlNode.textContent = nodeValue;
			} else {
				if(xmlNode.textContent == undefined) {
					xmlNode.text = nodeValue;
				} else {
					xmlNode.textContent = nodeValue;
				}
			}
			*/
		}
		
		/*
		function isExploreSupportWebkit() {
			var isWebKit = $.browser.webkit;

			if(isWebKit == undefined) {
				return false;
			} else {
				return isWebKit;
			}
		}
		*/
		
		function isMSIE() {
		    if($.browser != undefined) {
		        return $.browser.msie;
		    } else {
		        return false;
		    }
		}

		this.parseXML = function(xmlContent) {
			return myParseXML(xmlContent);
		};
		
		this.getXmlNodeFirstChild = function(xmlNode) {
			return getFirstChild(xmlNode);
		};
		
		this.getXmlNodeNextSibling = function(xmlNode) {
			return getNextSibling(xmlNode);
		};

		this.clearNodeValue = function(domNode, depth, attributeName) {
			var rootNode = domNode;
			if(domNode.length != undefined) {
				rootNode = domNode[0];
			}

			traverseDomNodeFilteredByAttributeName(
					rootNode, depth, attributeName,
					function(nodeTmp, depthTmp) {
					},
					function(nodeTmp, depthTmp) {
					},
					function(nodeTmp, depthTmp) {
						
			        	SetDomNodeValue(nodeTmp, "");
	            	}
			);
		};

		this.setNodeReadOnly = function(domNode, depth, attributeName) {
			var rootNode = domNode;
			if(domNode.length != undefined) {
				rootNode = domNode[0];
			}

			traverseDomNodeFilteredByAttributeName(
					rootNode, depth, attributeName,
					function(nodeTmp, depthTmp) {
					},
					function(nodeTmp, depthTmp) {
					},
					function(nodeTmp, depthTmp) {
						
						setDomNodeReadOnly(nodeTmp);
	            	}
			);
		};
		
		function setDomNodeReadOnly(node) {
			if(node.tagName.toLowerCase() == "input") {
				if(node.type.toLowerCase() == "radio")
				{
					//visit all sibling
					var nodeTmp = node;
					var radioName = node.name;

					while(nodeTmp != null)
					{
						if(!isXmlNodeTextType(nodeTmp)
							&& nodeTmp.tagName.toLowerCase() == "input"
							&& nodeTmp.type.toLowerCase() == "radio"
							&& nodeTmp.name == radioName)
						{
							nodeTmp.disabled = true;
						} 
						
						nodeTmp = getNextSibling(nodeTmp);
					}
				}
				else if(node.type.toLowerCase() == "checkbox")
				{
					node.disabled = true;
				}
				else 
				{
					node.readOnly = true;
				}
			} // if input <-
			else if(node.tagName.toLowerCase() == "select") 
			{
				node.disabled = true;
			} else if(node.tagName.toLowerCase() == "textarea") {
				node.readOnly = true;
			} else {
				var radioChildren = $(node).find('input[type="radio"]');
				if(radioChildren.length > 0) {
					for(var i = 0; i < radioChildren.length; i++) {
						radioChildren[i].disabled = true;
					}
				} else {
					//node.innerText = value;
					//$(node).text(value);
				}
			}
		}
		
		this.parseXML = function (xmlContent) {
			return myParseXML(xmlContent);
		};
		
		function myParseXML(xmlContent) {
			if(isMSIE()){
				var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
				xmlDoc.async = false;
				xmlDoc.loadXML(xmlContent);
				return xmlDoc;
			} else {
				return $.parseXML(xmlContent);
			}
		}
		
		function getFirstChild(xmlNode) {
			if(xmlNode.firstElementChild == undefined) {
				return xmlNode.firstChild;
			} else {
				return xmlNode.firstElementChild;
			}
		}
		
		function getFirstChildByAttributeName(xmlNode, attributeName) {
			var findResult = $(xmlNode).find('[' + attributeName + ']'); 
			if(findResult.length > 0) {
				return findResult[0];
			} else {
				return null;
			}
		}
		
		function getNextSibling(xmlNode) {
			if(xmlNode.nextElementSibling == undefined) {
				return xmlNode.nextSibling;
			} else {
				return xmlNode.nextElementSibling;
			}
		}

		this.getFirstChildNodeExceptTextAndComment = function (xmlNode) {
		    return getFirstChildNotTextNode(xmlNode);
		};

        this.getNextSiblingNodeExceptTextAndComment = function (xmlNode) {
            return getNextSiblingNotTextNode(xmlNode);
        };

		function getFirstChildNotTextNode(xmlNode) {
			var nodeTmp = getFirstChild(xmlNode);
			while((nodeTmp != undefined) && (nodeTmp.nodeType == 3 || nodeTmp.nodeType == 8)) {
				nodeTmp = getNextSibling(nodeTmp);
			}
			return nodeTmp;
		}

		function getNextSiblingNotTextNode(xmlNode) {
			var nodeTmp = getNextSibling(xmlNode);
			while((nodeTmp != undefined) && (nodeTmp.nodeType == 3 || nodeTmp.nodeType == 8)) {
				nodeTmp = getNextSibling(nodeTmp);
			}
			return nodeTmp;
		}
		
	}
	
	//Expose
	window.easyJsDomUtil = easyJsDomUtil;

})(window);

