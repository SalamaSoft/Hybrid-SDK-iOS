/**
* MIT License
* @author salama soft
* @api private
*/
(function( window, undefined ) {
	var nativeService = new NativeService();

	function NativeService() 
	{
		var debugMode = false;//false:not in debugging true:debugging in web explorer
		
		initDebugMode();
		
		function initDebugMode() {
			var userAgentInfo = navigator.userAgent.toLowerCase(); 
			if(userAgentInfo.indexOf("iphone") >= 0
				|| userAgentInfo.indexOf("android") >= 0 
				|| userAgentInfo.indexOf("winphone") >= 0 
				|| userAgentInfo.indexOf("ipad") >= 0 
				) {
				debugMode = false;
			} else {
				debugMode = true;
			}
		}
				
		this.setDebugMode = function(mode) {
			debugMode = mode;
		};
		
		this.getDebugMode = function() {
			return debugMode; 
		};

		//Current version -------------------------------------------------------------------------------------------------
		//The cmd format is below:
		//nativeService://<InvokeMsg>
		//  <target></target>
		//  <method></method>
		//  <params>
		//    <String>xxxxx</String>
		//    <String>xxxxx</String>
		//    <String>xxxxx</String>
		//    <String>xxxxx</String>
		//  </params>
		//  <callBackWhenSucceed></callBackWhenSucceed>
		//  <callBackWhenError></callBackWhenError>
		//  <notification></notification>
		//</InvokeMsg>
		
		var VALUE_STACK_PARAM_FLAG = "$";

		var PREFIX_NATIVE_SERVICE = "nativeService://";
		
        var TAG_LIST_MSG_0 = "<List>";
        var TAG_LIST_MSG_1 = "</List>";

		var TAG_INVOKE_MSG_0 = "<InvokeMsg>";
		var TAG_INVOKE_MSG_1 = "</InvokeMsg>";

        var TAG_IS_ASYNC_0 = "<isAsync>";
        var TAG_IS_ASYNC_1 = "</isAsync>";
		
		var TAG_TARGET_0 = "<target>";
		var TAG_TARGET_1 = "</target>";

		var TAG_METHOD_0 = "<method>";
		var TAG_METHOD_1 = "</method>";

        var TAG_RETURN_VALUE_KEEPER_0 = "<returnValueKeeper>";
        var TAG_RETURN_VALUE_KEEPER_1 = "</returnValueKeeper>";

        var TAG_KEEPER_SCOPE_0 = "<keeperScope>";
        var TAG_KEEPER_SCOPE_1 = "</keeperScope>";

		var TAG_PARAMS_0 = "<params>";
		var TAG_PARAMS_1 = "</params>";

		var TAG_PARAM_0 = "<String>";
		var TAG_PARAM_1 = "</String>";
		
		var TAG_CALL_BACK_WHEN_SUCCEED_0 = "<callBackWhenSucceed>";
		var TAG_CALL_BACK_WHEN_SUCCEED_1 = "</callBackWhenSucceed>";
		
		var TAG_CALL_BACK_WHEN_ERROR_0 = "<callBackWhenError>";
		var TAG_CALL_BACK_WHEN_ERROR_1 = "</callBackWhenError>";
		
		var TAG_NOTIFICATION_0 = "<notification>";
		var TAG_NOTIFICATION_1 = "</notification>";
		

		 //Format of callBackWhenSucceed: function(returnValue) .
		 //Format of callBackWhenError: function(erroMsg). The errorMsg is a String.
		this.invoke = function (args) {
			if(debugMode == false) {
				//normal
			    if(args.length == undefined) {
					var callBackWhenSucceed = "";
					if(args.success != undefined) {
						callBackWhenSucceed = args.success;
					} else if(args.callBackWhenSucceed != undefined) {
						callBackWhenSucceed = args.callBackWhenSucceed;
					}
					var callBackWhenError = "";
					if(args.error != undefined) {
						callBackWhenError = args.error;
					} else if(args.callBackWhenError != undefined) {
						callBackWhenError = args.callBackWhenError;
					}

	                invokeService(
	                        args.target, 
	                        args.method, 
	                        args.params,
	                        callBackWhenSucceed,
	                        callBackWhenError,
	                        args.isAsync,
	                        args.returnValueKeeper,
	                        args.keeperScope,
	                        args.notification
	                        );
			    } else {
	                invokeServiceBlock(args);
			    }
			} else {
				//debug
				debugNativeService.invoke(args);
			}
			
		};

		function invokeService(target, method, params, callBackWhenSucceed, callBackWhenError, isAsync, 
		    returnValueKeeper, keeperScope, notification) {

			var cmd = formatToNativeServiceCmd(
			    target, 
				method, 
				params,
				callBackWhenSucceed,
				callBackWhenError,
				isAsync,
				returnValueKeeper,
				keeperScope,
				notification
				);
            
            cmd = PREFIX_NATIVE_SERVICE + encodeCmd(cmd);
            
			//window.location = cmd;
			loadCmd(cmd);
		}
		
        function invokeServiceBlock(args) {
            var i;
            var cmd = TAG_LIST_MSG_0;

			var callBackWhenSucceed;
			var callBackWhenError;
			
            for(i = 0; i < args.length; i++) {
				callBackWhenSucceed = "";
				if(args[i].success != undefined) {
					callBackWhenSucceed = args[i].success;
				} else if(args[i].callBackWhenSucceed != undefined) {
					callBackWhenSucceed = args[i].callBackWhenSucceed;
				}
				callBackWhenError = "";
				if(args[i].error != undefined) {
					callBackWhenError = args[i].error;
				} else if(args[i].callBackWhenError != undefined) {
					callBackWhenError = args[i].callBackWhenError;
				}
                cmd += formatToNativeServiceCmd(
                    args[i].target, 
                    args[i].method, 
                    args[i].params,
                    callBackWhenSucceed,
                    callBackWhenError,
                    args[i].isAsync,
                    args[i].returnValueKeeper,
                    args[i].keeperScope,
                    args[i].notification
                    );
            }
            
            cmd += TAG_LIST_MSG_1;
            

            cmd = PREFIX_NATIVE_SERVICE + encodeCmd(cmd);

            loadCmd(cmd);
        }
		
		function encodeCmd(cmd) {
			//因Android的WebView中，URL中的"!()*"需要转换为百分号编码，
			//而JavaScript的encodeURIComponent中未转换这些字符，故需要自行处理
			return encodeURIComponent(cmd)
				.replace(/!/g, '%21')
				.replace(/\(/g, '%28')
				.replace(/\)/g, '%29')
				.replace(/\*/g, '%2A')
				;
		}
		
		function loadCmd(cmd) {
            var iFrame;
            iFrame = document.createElement("iframe");
            
            iFrame.setAttribute("src", cmd);
            iFrame.setAttribute("style", "display:none;");
            iFrame.setAttribute("height", "0px");
            iFrame.setAttribute("width", "0px");
            iFrame.setAttribute("frameborder", "0");
            
            document.body.appendChild(iFrame);
            
            // 发起请求后这个iFrame就没用了，所以把它从dom上移除掉
            iFrame.parentNode.removeChild(iFrame);
            iFrame = null;
    	}
		
		function formatToNativeServiceCmd(target, method, params, callBackWhenSucceed, callBackWhenError, 
		    isAsync, returnValueKeeper, keeperScope, notification) {
		    var cmd = "";
				
			cmd += TAG_INVOKE_MSG_0;
			
			cmd += TAG_TARGET_0 + target + TAG_TARGET_1;
			cmd += TAG_METHOD_0 + method + TAG_METHOD_1;

            if((isAsync != null) && (isAsync != undefined)) {
              if(!isAsync) {
                  //
                cmd += TAG_IS_ASYNC_0 + 'false' + TAG_IS_ASYNC_1;
              } else {
                cmd += TAG_IS_ASYNC_0 + 'true' + TAG_IS_ASYNC_1;
              }
            } else {
                //default
                cmd += TAG_IS_ASYNC_0 + 'false' + TAG_IS_ASYNC_1;
            }
            
            if((returnValueKeeper != null) && (returnValueKeeper != undefined)) {
                cmd += TAG_RETURN_VALUE_KEEPER_0 + returnValueKeeper + TAG_RETURN_VALUE_KEEPER_1;
            }

            if((keeperScope != null) && (keeperScope != undefined)) {
                cmd += TAG_KEEPER_SCOPE_0 + keeperScope + TAG_KEEPER_SCOPE_1;
            }

            if((notification != null) && (notification != undefined)) {
                cmd += TAG_NOTIFICATION_0 + notification + TAG_NOTIFICATION_1;
            }
            //params ---------------------------------------
			cmd += TAG_PARAMS_0;
			var propNameTmp = null;
			
			var obj = null;
			
			if((params != undefined) && (params != null)) {
				for(var i = 0; i < params.length; i++) {
				    //handle the case: {name:obj}
				    if(params[i] != null && isObjectType(params[i])) {
			            propNameTmp = null;
                        for(propNameTmp in params[i]) {
                            if(propNameTmp != null) {
                                obj = (params[i])[propNameTmp];
                                break;
                            }
                        }
                        
                        if(propNameTmp == VALUE_STACK_PARAM_FLAG) {
                        	   //{"$":string}
                            cmd += TAG_PARAM_0 + easyJsDomUtil.encodeXml(simpleXml.varToXml(
                            	VALUE_STACK_PARAM_FLAG + obj)) + TAG_PARAM_1;
                        } else {
		                    if(propNameTmp != null && isObjectType(obj)) {
		                        //{name:obj}
		                            cmd += TAG_PARAM_0 + easyJsDomUtil.encodeXml(simpleXml.varToXml(obj, propNameTmp)) + TAG_PARAM_1;
		                    } else {
		                        //obj
		                        cmd += TAG_PARAM_0 + easyJsDomUtil.encodeXml(simpleXml.varToXml(params[i])) + TAG_PARAM_1;
		                    }
                        }
				    } else {
                        cmd += TAG_PARAM_0 + easyJsDomUtil.encodeXml(simpleXml.varToXml(
                        	encodeStrParam(params[i]))) + TAG_PARAM_1;
				    }
				}
			}
			cmd += TAG_PARAMS_1;

			cmd += TAG_CALL_BACK_WHEN_SUCCEED_0 + callBackWhenSucceed + TAG_CALL_BACK_WHEN_SUCCEED_1;
			cmd += TAG_CALL_BACK_WHEN_ERROR_0 + callBackWhenError + TAG_CALL_BACK_WHEN_ERROR_1;
			
			cmd += TAG_INVOKE_MSG_1;

			return cmd;
		}
		
		function encodeStrParam(val) {
			if(isStringType(val)) {
				if(val != null && val.charAt(0) == '$') {
					return '$' + val;
				} else {
					return val;
				}
			} else {
				return val;
			}
		}
		
		function isObjectType(val) {
		    if((typeof val).toLowerCase() == "object") {
		        return true;
		    } else {
		        return false;
		    }
		}
		
		function isStringType(val) {
	        var typeName = (typeof val).toLowerCase(); 
	        if(typeName == "string") {
	        	return true;
	        } else {
	        	return false;
	        }
		}
	}
	
	//Expose
	window.nativeService = nativeService;
	
})(window);
