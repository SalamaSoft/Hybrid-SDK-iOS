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
	var debugNativeService = new DebugNativeService();

	function DebugNativeService() 
	{
		 //Format of callBackWhenSucceed: function(returnValue) .
		 //Format of callBackWhenError: function(erroMsg). The errorMsg is a String.
		this.invoke = function (args) {
		    if(args.length == undefined) {
				var callBackWhenSucceed = args.success;
				if(callBackWhenSucceed == undefined) {
					callBackWhenSucceed = args.callBackWhenSucceed;
				}
				var callBackWhenError = args.error;
				if(callBackWhenError == undefined) {
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
                        args.keeperScope
                        );
		    } else {
                invokeServiceBlock(args);
		    }
			
		};

        function invokeServiceBlock(args) {
            var i;
			var callBackWhenSucceed;
			var callBackWhenError;

            for(i = 0; i < args.length; i++) {
				callBackWhenSucceed = args[i].success;
				if(callBackWhenSucceed == undefined) {
					callBackWhenSucceed = args[i].callBackWhenSucceed;
				}
				callBackWhenError = args[i].error;
				if(callBackWhenError == undefined) {
					callBackWhenError = args[i].callBackWhenError;
				}
                invokeService(
                        args[i].target, 
                        args[i].method, 
                        args[i].params,
                        callBackWhenSucceed,
                        callBackWhenError,
                        args[i].isAsync,
                        args[i].returnValueKeeper,
                        args[i].keeperScope
                        );
            }
        }

		function invokeService(target, method, params, callBackWhenSucceed, callBackWhenError, isAsync, 
			returnValueKeeper, keeperScope) {
	    	if(target == "thisView") {
	    		if(method == "registerJSCallBackToNotification") {
	    			//notificationJSMap[params[0]] = params[1];
	    			setDebugVar("notificationJSMap", params[0], params[1]);
	    		} else if(method == "createPageView") {
	    			//tempVarMap[returnValueKeeper] = params[0];
	    			setDebugVar("tempVarMap", returnValueKeeper, params[0]);
	    		} else if(method == "presentPageView") {
	    			//window.location = tempVarMap[(params[0])["$"]];		    			
	    			window.location = getDebugVar("tempVarMap", (params[0])["$"]);
	    		} else if(method == "pushPageView") {
	    			//window.location = tempVarMap[(params[0])["$"]];			
	    			window.location = getDebugVar("tempVarMap", (params[0])["$"]);
	    		} else if(method == "getTransitionParamByName") {
	    			var func = eval(callBackWhenSucceed); 
	    			new func(getDebugVar("transitionParamMap", params[0]));
	    		} else if(method == "setSessionValueWithName") {
	    			//sessionValueMap[params[0]] = params[1];
	    			setDebugVar("sessionValueMap", params[0], params[1]);
	    		} else if(method == "getSessionValueWithName") {
	    			var func = eval(callBackWhenSucceed); 
	    			new func(getDebugVar("sessionValueMap", params[0]));
	    		} else if(method == "removeSessionValueWithName") {
	    			//sessionValueMap[params[0]] = null;
	    			removeDebugVar("sessionValueMap", params[0]);
	    		} else if (method == "showAlert") {
	    			alert(params[1]);
	    		} else if (method == "popSelf") {
	    			window.history.back();
	    		} else if (method == "popToPage") {
	    			window.history.go(params[0]);
	    		}	    		
	    		
	    	} else {
	    		if(method == "setTransitionParam") {
	    			//transitionParamMap[params[1]] = params[0];
	    			setDebugVar("transitionParamMap", params[1], params[0]);
	    		}
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
		
		// var notificationJSMap = new Object();
		// var tempVarMap = new Object();
		// var transitionParamMap = new Object();
		// var sessionValueMap = new Object();

		function setDebugVar(objName, varName, varVal) {
			sessionStorage[objName + "." + varName] = varVal;
		}	
		
		function getDebugVar(objName, varName) {
			var varVal = sessionStorage[objName + "." + varName];
			if(varVal == null || varVal == undefined) {
				return "";
			} else {
				return varVal;
			}
		}
		
		function removeDebugVar(objName, varName) {
			sessionStorage.removeItem(objName + "." + varName);
		}	
	}
	
	//Expose
	window.debugNativeService = debugNativeService;
	
})(window);
