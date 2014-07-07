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
(function( window, undefined ) {
	var simpleXml = new SimpleXml();

	function SimpleXml() 
	{
		//Current version -------------------------------------------------------------------------------------------------
		//There are 3 Type tag name: <double><String>,<List>,<Object>

        var NODE_NAMES = ["String", "double", "Object", "List"];

        var VAR_TYPE_STRING = 0;
        var VAR_TYPE_NUMBER = 1;
        var VAR_TYPE_OBJECT = 2;
        var VAR_TYPE_LIST = 3;

		this.varToXml = function (val, nodeName) {
		    var nodeNameTmp = nodeName;
		    if(nodeName == undefined) {
		        nodeNameTmp = null;
		    }
		    
		    return variableToXml(val, nodeNameTmp);
		};
		
		this.xmlToVar = function (xml) {
		    return xmlToVariable(xml);
		};
		
        //------------------------------------------ var to xml --------------------------------------------
		function variableToXml(val, nodeName) {
            var varType = getVarType(val);
            var nodeNameTmp;
            if(isNull(nodeName)) {
                 nodeNameTmp = NODE_NAMES[varType];
            } else {
                nodeNameTmp = nodeName;
            }
            
            if(varType == VAR_TYPE_STRING) {
                return stringToXml(val, nodeNameTmp); 
            } else if (varType == VAR_TYPE_NUMBER) {
                return numberToXml(val, nodeNameTmp);
            } else if (varType == VAR_TYPE_LIST) {
                return listToXml(val, nodeNameTmp);
            } else {
                //(varType == VAR_TYPE_OBJECT)
                return objectToXml(val, nodeNameTmp);
            }
		}
		
		
		function stringToXml(val, nodeName) {
            if(isNull(val)) {
                return "";
            } else {
                var nodeNameTmp;
                
                if(isNull(nodeName)) {
                     nodeNameTmp = NODE_NAMES[VAR_TYPE_STRING];
                } else {
                    nodeNameTmp = nodeName;
                }
                
                return makeNodeXml(nodeNameTmp, val); 
            }
		}

        function numberToXml(val, nodeName) {
            if(isNull(val)) {
                return "";
            } else {
                var nodeNameTmp;
                
                if(isNull(nodeName)) {
                     nodeNameTmp = NODE_NAMES[VAR_TYPE_NUMBER];
                } else {
                    nodeNameTmp = nodeName;
                }
                
                return makeNodeXml(nodeNameTmp, val + ""); 
            }
        }
		
		function objectToXml(val, nodeName) {
		    if(isNull(val)) {
		        return "";
		    } else {
                var nodeNameTmp;
                
                if(isNull(nodeName)) {
                     nodeNameTmp = NODE_NAMES[VAR_TYPE_NUMBER];
                } else {
                    nodeNameTmp = nodeName;
                }

                var xml = makeBeginTag(nodeNameTmp);
                
                for(var propName in val) {
                    if(!isNull(val[propName])) {
                        xml += variableToXml(val[propName], propName);
                    }
                }
                
                xml += makeEndTag(nodeNameTmp);
		        
		        return xml;
		    }
		}

        function listToXml(val, nodeName) {
            var nodeNameTmp;
            if(isNull(nodeName)) {
                 nodeNameTmp = NODE_NAMES[VAR_TYPE_LIST];
            } else {
                nodeNameTmp = nodeName;
            }
            
            var xml = makeBeginTag(nodeNameTmp);
            
            for(var i = 0; i < val.length; i++) {
                xml += variableToXml(convertToStringIfNumberType(val[i]), null);
            }
            
            xml += makeEndTag(nodeNameTmp);
            
            return xml;
        }
		
        function makeNodeXml(nodeName, nodeValue) {
            return "<" + nodeName + ">" + easyJsDomUtil.encodeXml(nodeValue) + "</" + nodeName + ">"; 
        }
        
        function makeBeginTag(nodeName) {
            return "<" + nodeName + ">";
        }
        
        function makeEndTag(nodeName) {
            return "</" + nodeName + ">";
        }
		
		//------------------------------------------ xml to var --------------------------------------------
        function xmlToVariable(xml) {
            if(xml == "") {
                return null;
            }
            
            var xmlDoc = easyJsDomUtil.parseXML(xml);
            var rootNode = xmlDoc.firstChild;
            
            return xmlNodeToVariable(rootNode);
        }

        function xmlNodeToVariable(xmlNode) {
            var nodeName;
            nodeName = xmlNode.nodeName;
            
            var nodeTmp = easyJsDomUtil.getFirstChildNodeExceptTextAndComment(xmlNode);

            if(nodeTmp != null) {
                var isList = false;
                if (nodeName == NODE_NAMES[VAR_TYPE_LIST]) {
                    isList = true;
                } else {
                    var nodeTmp2 = easyJsDomUtil.getNextSiblingNodeExceptTextAndComment(nodeTmp);
                    if(nodeTmp2 != null && nodeTmp2.nodeName == nodeTmp.nodeName) {
                        isList = true;
                    }
                }
                
                if(isList) {
                    var obj = new Array();
                    
                    var i = 0;
                    while(nodeTmp != null) {
                        obj[i] = xmlNodeToVariable(nodeTmp);
                     
                        nodeTmp = easyJsDomUtil.getNextSiblingNodeExceptTextAndComment(nodeTmp);   
                        i++;
                    }
                    
                    return obj;
                } else {
                    var obj = new Object();
                    
                    while(nodeTmp != null) {
                        obj[nodeTmp.nodeName] = xmlNodeToVariable(nodeTmp);
                     
                        nodeTmp = easyJsDomUtil.getNextSiblingNodeExceptTextAndComment(nodeTmp);   
                    }

                    return obj;                    
                }
                
            } else {
                //leaf node
                if(nodeName == NODE_NAMES[VAR_TYPE_STRING]) {
                    return xmlNodeToString(xmlNode);
                } else if(nodeName == NODE_NAMES[VAR_TYPE_NUMBER]) {
                    return xmlNodeToNumber(xmlNode);
                } else if (nodeName == NODE_NAMES[VAR_TYPE_OBJECT]) {
                    return new Object();
                } else if (nodeName == NODE_NAMES[VAR_TYPE_LIST]) {
                    return new Array();
                } else {
                    //treat it as string
                    return xmlNodeToString(xmlNode);
                }
            }
            
        }
                
        function xmlNodeToString(xmlNode) {
            return easyJsDomUtil.decodeXml($(xmlNode).text());
        }
        
        function xmlNodeToNumber(xmlNode) {
            return easyJsDomUtil.decodeXml($(xmlNode).text()) * 1;
        }
		
        //------------------------------------------ utils --------------------------------------------
		function getVarType(val) {
		    if(val == null || val == undefined) {
		        return VAR_TYPE_STRING;
		    } else {
		        var typeName = (typeof val).toLowerCase(); 
		        
		        if(typeName == "string") {
		            return VAR_TYPE_STRING;
		        } else if (typeName == "number") {
		            return VAR_TYPE_NUMBER;
		        } else if (typeName == "object") {
                    if(val.length != undefined) {
                        return VAR_TYPE_LIST;
                    } else {
                        return VAR_TYPE_OBJECT;
                    }
		        } else {
                    return VAR_TYPE_STRING;
		        }
		    }
		}
		
		function isNull(val) {
		    if(val == null || val == undefined) {
		        return true;
		    } else {
		        return false;
		    }
		}
		
		function isArray() {
		    return (val.length != undefined);
		}
		
		function convertToStringIfNumberType(val) {
		    if(val != null && val != undefined && (typeof val).toLowerCase() == "number") {
		        return val + "";
            } else {
                return val;
            }
		}

	}
	
	//Expose
	window.simpleXml = simpleXml;
	
})(window);
