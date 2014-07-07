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
	var salamaAjaxUtil = new SalamaAjaxUtil();
    var _jsonPID = 1;

	function SalamaAjaxUtil() 
	{
		var DEFAULT_REQUEST_TIMEOUT_MILLISECONDS = 30000;
		
		/**
		 * jsonp方式调用Web Service
		 * @param args{url:"", params:[p1:"" p2:"", ...], success:function(){}, error:function(){}}
		 */
		this.doJsonpWebService = function (args) {
			var callbackWhenAjaxSuccess = args.success;
			if(callbackWhenAjaxSuccess == undefined) {
				callbackWhenAjaxSuccess = args.callbackWhenAjaxSuccess;
			}
			var callbackWhenAjaxError = args.error;
			if(callbackWhenAjaxError == undefined) {
				callbackWhenAjaxError = args.callbackWhenAjaxError;
			}
			
            doJsonP(args.url, args.params, 
            	callbackWhenAjaxSuccess, callbackWhenAjaxError, 
            	args.timeout);
		};
		
		function doJsonP(url, params, callbackWhenAjaxSuccess, callbackWhenAjaxError, timeout) {
			var fullURL = url;
			
			var i = 0;
            for(var paramName in params) {
            	if(i == 0) {
					fullURL += "?" + paramName + "=" + encodeURIComponent(params[paramName]);
            	} else {
					fullURL += "&" + paramName + "=" + encodeURIComponent(params[paramName]);
            	}
				
				i++;
			}
			
			if(i == 0) {
				fullURL += "jsoncallback=?";
			} else {
				fullURL += "&jsoncallback=?";
			}
			
			var timeoutTmp = DEFAULT_REQUEST_TIMEOUT_MILLISECONDS;
			if(timeout > 0) {
				timeoutTmp = timeout;
			}
			
			if(isUsingJquery()) {
	            var callbackName = 'jsonp_callback' + (++_jsonPID);
	            fullURL = fullURL.replace(/=\?/, '=' + callbackName);
				$.ajax({
					url: fullURL,
					dataType: "script",
					timeout: timeoutTmp,
					success : function(eventData) {
						//Handle success
						if(callbackWhenAjaxSuccess != null 
							&& callbackWhenAjaxSuccess != undefined) {
							callbackWhenAjaxSuccess(eventData);
						}
					},
					error : function(eventData, error) {
						//Handle error
						if(callbackWhenAjaxError != null 
							&& callbackWhenAjaxError != undefined) {
							callbackWhenAjaxError(error);
						}
					}
				});
			} else {
				//Use the customized jsonp function instead of using .ajax of jqMobi, 
				//because there is a bug in this version of jqMobi.
				jsonP({
					url: fullURL,
					timeout: timeoutTmp,
					success : function(eventData) {
						//Handle success
						if(callbackWhenAjaxSuccess != null 
							&& callbackWhenAjaxSuccess != undefined) {
							callbackWhenAjaxSuccess(eventData);
						}
					},
					error : function(eventData, error) {
						//Handle error
						if(callbackWhenAjaxError != null 
							&& callbackWhenAjaxError != undefined) {
							callbackWhenAjaxError(error);
						}
					}
				});
			}
		}

        function jsonP(options) {
            var callbackName = 'jsonp_callback' + (++_jsonPID);
            var abortTimeout = "", 
            context;
            var script = document.createElement("script");
            var abort = function() {
                $(script).remove();
                if (window[callbackName])
                    window[callbackName] = empty;
            };
            window[callbackName] = function(data) {
                clearTimeout(abortTimeout);
                $(script).remove();
                delete window[callbackName];
                options.success.call(context, data);
            };
            //script.type="text/x-www-form-urlencoded";
            script.type="text/javascript";
            script.language = "jsonp";
            script.src = options.url.replace(/=\?/, '=' + callbackName);
            script.onload = window[callbackName];
            
            if(options.error)
            {
               script.onerror=function(){
                  clearTimeout(abortTimeout);
                  options.error.call(context, "", 'error');
               }
            }
            $('head').append(script);
            if (options.timeout > 0)
                abortTimeout = setTimeout(function() {
                    options.error.call(context, "", 'timeout');
                }, options.timeout);
            return {};
        }

		function isUsingJquery() {
			return ($(document.body).after != undefined);
		}
	}
	
	//Expose
	window.salamaAjaxUtil = salamaAjaxUtil;
	
})(window);
