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
	var salama = new Salama();
	
	try {
	function Salama() {
		var _debugMode = false;
		var _offLineDebugMode = false;
		var _appAuthInfo = {};
		var _appServiceHttpUrl = null;
		var _appServiceHttpsUrl = null;
		var _myAppServiceHttpUrl = null;
		var _myAppServiceHttpsUrl = null;

		
		var _sqlUtil = new SalamaSqlUtil();
		this.sqlUtil = _sqlUtil;

		var _native = new SalamaNative();
		this.native = _native;

		var _cloud = new SalamaCloud()		
		this.cloud = _cloud;
		
		var _webService = new SalamaWebService();
		this.webService = _webService;
		
		var _user = new SalamaUser();
		this.user = _user;

		/**
		 * 初始化
		 */
		$(document).ready(function(){
			initAppInfoFromNative();
		});

		function initAppInfoFromNative() {
			if(_offLineDebugMode) {
				dispatchSalamaReady();
				return;
			}
			if(_debugMode) {
				appLogin(function(){
					dispatchSalamaReady();
				});
			} else {
				_native.invoke({
					target: 'salama', 
					method: 'getAppInfo', 
					params: null, 
					success: function(result) {
						onGetAppInfoFromNative(result);
					}
				});
			}				
		}
		
		function onGetAppInfoFromNative(result) {
			if(result != undefined && result.length > 0) {
				var appInfo = simpleXml.xmlToVar(result);
				
				_appServiceHttpUrl = appInfo.appServiceHttpUrl;
				_appServiceHttpsUrl = appInfo.appServiceHttpsUrl;
				
				//在手机中运行时，app认证信息在手机程序中，JS中无需保存
				_appAuthInfo.appId = "";
				_appAuthInfo.appSecret = "";
				_appAuthInfo.appToken = "";
			}
			
			dispatchSalamaReady();
		}
		
		function dispatchSalamaReady() {
			//delay dispatching event
			var delayTimeout = setTimeout(function() {
				clearTimeout(delayTimeout);
				delayTimeout = null;
	
				var ev = document.createEvent('HTMLEvents');
				ev.initEvent("SalamaReady", false, true);
				document.dispatchEvent(ev);
				/* deprecated
				if(window['SalamaReadyFunc'] != undefined && window['SalamaReadyFunc'] != null) {
					window['SalamaReadyFunc']();
				}
				*/
			}, 1);
		}
		
		this.appServiceHttpUrl = _appServiceHttpUrl;
		this.appServiceHttpsUrl = _appServiceHttpsUrl;
		
		/**
		 * 初始化完成时触发的事件
		 */
		this.ready = function(callback) {
			document.addEventListener("SalamaReady", callback, false);
			
			//deprecated
			//window['SalamaReadyFunc'] = callback;
		};

		/**
		 * 初始化debug离线模式
		 */
		this.initOffLineDebugMode = function() {
			_debugMode = true;
			_offLineDebugMode = true;
		};

		/**
		 * 初始化debug模式，用于在浏览器调试
		 * @param args{appId:"", appSecret:"", appToken:"", userId:"", authTicket:"", expiringTime:xxxxxx, loginId:""}
		 */
		this.initDebugMode = function (args) {
			_debugMode = true;
			
			_appAuthInfo.appId = args.appId;
			_appAuthInfo.appSecret = args.appSecret;
			
			var serverNum = _appAuthInfo.appId.substring(4, 2);
			var httpPort = 30000 + parseInt(serverNum, 16);
			var httpsPort = 40000 + parseInt(serverNum, 16);
			_appServiceHttpUrl = "http://dev" + _appAuthInfo.appId.substring(0, 4) + ".salama.com.cn:" + String(httpPort) + "/easyApp/cloudDataService.do";
			//DebugMode does not use https
			_appServiceHttpsUrl = "http://dev" + _appAuthInfo.appId.substring(0, 4) + ".salama.com.cn:" + String(httpPort) + "/easyApp/cloudDataService.do";
			
			//Debug in localhost
			//_appServiceHttpUrl = "http://127.0.0.1:8080/easyApp/cloudDataService.do";
			//_appServiceHttpsUrl = "http://127.0.0.1:8080/easyApp/cloudDataService.do";

			_user.initDebugMode(args);
		};
		
		function appLogin(callback) {
			var utcTime = (new Date()).getTime();
			var utcTimeMD5 = md5.md5(String(utcTime));
			var appSecretMD5 = md5.md5(_appAuthInfo.appSecret);
			var appSecretMD5MD5 = md5.md5(appSecretMD5 + utcTimeMD5);
			_webService.doGet({
				url:_appServiceHttpsUrl,
				params:{
					serviceType:"com.salama.easyapp.service.AppAuthService", 
					serviceMethod:"appLogin",
					appId:_appAuthInfo.appId, 
					appSecretMD5MD5:appSecretMD5MD5, 
					utcTime:utcTime
					},
				success:function(result) {
					_appAuthInfo.appToken = $(result).find('appToken').text();
					_appAuthInfo.expiringTime = Number($(result).find('expiringTime').text());
					callback();
					},
				error:null
			});				
		}
		
		//------------------------  util ----------------------------------------
		function SalamaSqlUtil() {
			var _escapeSqlVal = function (sqlVal) {
				if(sqlVal == undefined || sqlVal == null) {
					return "";	
				} else {
					return sqlVal.replace(/\r/g, '\\r').replace(/\n/g, '\\n').replace(/'/g, "''");
				}
			};

			this.escapeSqlVal = _escapeSqlVal;

			/**
			 * @param sql: For example: "select * from T1 where c1 = ? and c2 = ?" 
			 * @param params: [c1Val, c2Val]
			 */
			this.makeSql = function(sql, params) {
				var newSql = "";
				var i;
				var c;
				var index = 0;
				var val;
				for(i = 0; i < sql.length; i++) {
					c = sql.charAt(i);
					if(c === '?') {
						val = params[index++];
						if((typeof val).toLowerCase() == "number") {
							newSql += String(val);
						} else {
							newSql += "'" + _escapeSqlVal(val) + "'";
						}
					} else {
						newSql += c;
					}
				}
				
				return newSql;
			};		
		}
		
		//------------------------  webService ----------------------------------------
		function SalamaWebService() {
			var _successPID = 0;
			var _errorPID = 0;
			var _jsonpReturnPID = 0;

			/**
			 * 调用Web Service(Get方法)
			 * @param args{url:"", params, success, error}
			 */
			this.doGet = function (args) {
				if(_debugMode === true) {
					doJsonP(args);
				} else {
					doBasicMethod('doGet', args);
				}
			};
			
			/**
			 * 调用Web Service(Post方法)
			 * @param args{url:"", params, success, error}
			 */
			this.doPost = function (args) {
				if(_debugMode === true) {
					doJsonP(args);
				} else {
					doBasicMethod('doPost', args);
				}
			};
			
			function doBasicMethod(wsMethod, args) {
				var paramNames = new Array();
				var paramValues = new Array();
				for(var paramName in args.params) {
					paramNames.push(paramName);
					paramValues.push(args.params[paramName]);
				}
				
				_native.invoke({
					target: 'salama.webService', 
					method: wsMethod, 
					params: [args.url, paramNames, paramValues], 
					success: args.success, 
					error: args.error
				});
			}
			
			function doJsonP(args) {
				var successFuncName = null;
				var errorFuncName = null;
				var jsonpReturnName = null;
				
				jsonpReturnName = "salama_ws_jsonp_val_" + String(++_jsonpReturnPID);
				args.params.jsonpReturn = jsonpReturnName;
				if(args.params.responseType == undefined) {
					args.params.responseType = "xml.jsonp";
				} else {
					args.params.responseType += ".jsonp";
				}
				
				if((args.success != undefined) && (args.success != null)) {
					successFuncName = "salama_ws_jsonp_suc_" + String(++_successPID);
					window[successFuncName] = function (data) {
						delete window[successFuncName];
						delete window[errorFuncName];
						args.success(decodeURIComponent(window[jsonpReturnName]));
						delete window[jsonpReturnName];
					};
				}
				if((args.error != undefined) && (args.error != null)) {
					errorFuncName = "salama_ws_jsonp_err_" + String(++_errorPID);
					window[errorFuncName] = function (data) {
						delete window[successFuncName];
						delete window[errorFuncName];
						delete window[jsonpReturnName];
						args.error(data);
					};
				}
				
				salamaAjaxUtil.doJsonpWebService({
					url: args.url,
					params: args.params,
					success: window[successFuncName],
					error: window[errorFuncName],
					timeout: args.timeout
				});
			}
			
			
		};

		//------------------------  user ----------------------------------------
		function SalamaUser() {
			//for debug mode
			var _userAuthInfo = new Object();
			this.userAuthInfo = _userAuthInfo;
			
			/* deprecated
			this.init = function (callback) {
				_native.invoke({
					target: 'salama.userService', 
					method: 'getUserAuthInfo', 
					params: null, 
					success: function (result) {
						setUserAuthInfoByXml(result);
						callback();
					}
				});
			}
			*/
			
			/**
			 * @param args{userId:"", authTicket:"", expiringTime:xxxxxx, loginId:""}
			 */
			this.initDebugMode = function (args) {
				_userAuthInfo.userId = (args.userId == undefined?"":args.userId);
				_userAuthInfo.authTicket = (args.authTicket == undefined?"":args.authTicket);
				_userAuthInfo.expiringTime = (args.expiringTime == undefined?0:args.expiringTime);
				_userAuthInfo.loginId = (args.loginId == undefined?"":args.loginId);
				
				if(_debugMode) {
					var xml = getUserAuthInfoXmlFromStorage();
					if(_userAuthInfo.authTicket.length == 0 
						&& xml != undefined && xml != null && xml.length > 0) {
						var userAuthInfoTmp = simpleXml.xmlToVar(xml);
						_userAuthInfo.userId = (userAuthInfoTmp.userId == undefined?"":userAuthInfoTmp.userId);
						_userAuthInfo.authTicket = (userAuthInfoTmp.authTicket == undefined?"":userAuthInfoTmp.authTicket);
						_userAuthInfo.expiringTime = (userAuthInfoTmp.expiringTime == undefined?0:userAuthInfoTmp.expiringTime);
					} else {
						xml = simpleXml.varToXml(_userAuthInfo, "UserAuthInfo");
						storeUserAuthInfoXmlToStorage(xml);
					}
				}
			};
			
			/**
			 * 取得用户认证信息
			 * @param args{success:function(result){}}
			 * @return 用户认证信息
			 */
			this.getUserAuthInfo = function (args) {
				if(_debugMode) {
					return getUserAuthInfoXmlFromStorage();
				} else {
					
					return _native.invoke({
						target: 'salama.userService', 
						method: "getUserAuthInfo", 
						params: null,
						success: (args == undefined || args == null)?null:args.success
					});
				}
			};
			
			/**
			 * 用户认证信息是否有效
			 * @param args{success:function(result){}}
			 * @return 1:有效(认证信息存在，票据未过期) 0:失效
			 */
			this.isUserAuthValid = function (args) {
				if(_debugMode) {
					if(_userAuthInfo == null || _userAuthInfo.authTicket == undefined || _userAuthInfo.authTicket == null || _userAuthInfo.authTicket.length == 0) {
						return 0;
					} else {
						if(_userAuthInfo.expiringTime <= (new Date()).getTime()) {
							return 0;
						} else {
							return 1;
						}
					}
				} else {
					return _native.invoke({
						target: 'salama.userService', 
						method: "isUserAuthValid", 
						params: null,
						success: (args == undefined || args == null)?null:args.success
					});
				}
			};
			
			/**
			 * @param args{loginId:"", password:"", success:function(result){}, error:function(errorInfo){}}
			 */
			this.signUp = function (args) {
				if(_debugMode === true) {
					var passwordMD5 = md5.md5(args.password);
					_webService.doGet({
						url:_appServiceHttpsUrl,
						params:{
							serviceType:"com.salama.easyapp.service.UserAuthService", 
							serviceMethod:"signUp",
							appToken:_appAuthInfo.appToken, 
							loginId:args.loginId, 
							passwordMD5:passwordMD5
							},
						success:function(result) {
							setUserAuthInfoByXml(result);
							_native.invoke({
								target: 'salama.userService', 
								method: 'storeUserAuthInfo', 
								params: [{UserAuthInfo:_userAuthInfo}], 
								success: null
							});
							
							if(args.success != undefined && args.success != null) {
								args.success(result);						
							}
						},
						error:args.error
					});				
				} else {
					_native.invoke({
						target: 'salama.userService', 
						method: 'signUp', 
						params: [args.loginId, args.password], 
						success:function(result) {
							setUserAuthInfoByXml(result);
							if(args.success != undefined && args.success != null) {
								args.success(result);						
							}
						},
						error:args.error
					});
				}
			};
			
			/**
			 * @param args{loginId:"", password:"", success:function(){} error:function(){}}
			 */
			this.login = function (args) {
				if(_debugMode === true) {
					var utcTime = (new Date()).getTime();
					var utcTimeMD5 = md5.md5(String(utcTime));
					var passwordMD5 = md5.md5(args.password);
					var passwordMD5MD5 = md5.md5(passwordMD5 + utcTimeMD5);
	
					_webService.doGet({
						url:_appServiceHttpsUrl,
						params:{
							serviceType:"com.salama.easyapp.service.UserAuthService", 
							serviceMethod:"login",
							appToken:_appAuthInfo.appToken, 
							loginId:args.loginId, 
							passwordMD5MD5:passwordMD5MD5, 
							utcTime:utcTime
							},
						success:function(result) {
							setUserAuthInfoByXml(result);
							_native.invoke({
								target: 'salama.userService', 
								method: 'storeUserAuthInfo', 
								params: [{UserAuthInfo:_userAuthInfo}], 
								success: null
							});
							if(args.success != undefined && args.success != null) {
								args.success(result);						
							}
						},
						error:args.error
					});				
				} else {
					_native.invoke({
						target: 'salama.userService', 
						method: 'login', 
						params: [args.loginId, args.password], 
						success:function(result) {
							setUserAuthInfoByXml(result);
							if(args.success != undefined && args.success != null) {
								args.success(result);						
							}
						},
						error:args.error
					});
				}
			};
			
			/**
			 * 用户登录(通过登录票据)
			 * @param args{authTicket:"", success:function(){} error:function(){}}
			 */
			this.loginByTicket = function (args) {
				if(_debugMode === true) {
					_webService.doGet({
						url:_appServiceHttpsUrl,
						params:{
							serviceType:"com.salama.easyapp.service.UserAuthService", 
							serviceMethod:"loginByTicket",
							appToken:_appAuthInfo.appToken, 
							authTicket:_userAuthInfo.authTicket},
						success:function(result) {
							if(result == undefined || result == null || result.length == 0) {
								_userAuthInfo.authTicket = "";
								_userAuthInfo.expiringTime = 0;
							} else {
								var userAuthInfoTmp = simpleXml.xmlToVar(result);
								_userAuthInfo.returnCode = (userAuthInfoTmp.returnCode == undefined?"":userAuthInfoTmp.returnCode);
								_userAuthInfo.userId = (userAuthInfoTmp.userId == undefined?"":userAuthInfoTmp.userId);
								_userAuthInfo.authTicket = (userAuthInfoTmp.authTicket == undefined?"":userAuthInfoTmp.authTicket);
								_userAuthInfo.expiringTime = (userAuthInfoTmp.expiringTime == undefined?0:userAuthInfoTmp.expiringTime);
							}
							_native.invoke({
								target: 'salama.userService', 
								method: 'storeUserAuthInfo', 
								params: [{UserAuthInfo:_userAuthInfo}], 
								success: null
							});
							if(args.success != undefined && args.success != null) {
								args.success(result);				
							}
						},
						error:args.error
					});				
				} else {
					_native.invoke({
						target: 'salama.userService', 
						method: 'loginByTicket', 
						params: null, 
						success: function(result) {
							if(result == undefined || result == null || result.length == 0) {
								_userAuthInfo.authTicket = "";
								_userAuthInfo.expiringTime = 0;
							} else {
								var userAuthInfoTmp = simpleXml.xmlToVar(result);
								_userAuthInfo.returnCode = (userAuthInfoTmp.returnCode == undefined?"":userAuthInfoTmp.returnCode);
								_userAuthInfo.userId = (userAuthInfoTmp.userId == undefined?"":userAuthInfoTmp.userId);
								_userAuthInfo.authTicket = (userAuthInfoTmp.authTicket == undefined?"":userAuthInfoTmp.authTicket);
								_userAuthInfo.expiringTime = (userAuthInfoTmp.expiringTime == undefined?0:userAuthInfoTmp.expiringTime);
							}
							if(args.success != undefined && args.success != null) {
								args.success(result);				
							}
						},
						error:args.error
					});
				}
			};
			
			/**
			 * 修改密码
			 * @param args{loginId:"", password:"", newPassword:"", success:function(){} error:function(){}}
			 */
			this.changePassword = function (args) {
				if(_debugMode === true) {
					var passwordMD5 = md5.md5(args.password);
					var newPasswordMD5 = md5.md5(args.newPassword);
					
					_webService.doGet({
						url:_appServiceHttpsUrl,
						params:{
							serviceType:"com.salama.easyapp.service.UserAuthService", 
							serviceMethod:"changePassword",
							appToken:_appAuthInfo.appToken, 
							loginId:args.loginId, 
							passwordMD5:passwordMD5, 
							newPasswordMD5:newPasswordMD5},
						success:args.success,
						error:args.error
					});				
				} else {
					_native.invoke({
						target: 'salama.userService', 
						method: 'changePassword', 
						params: [args.loginId, args.password, args.newPassword], 
						success: args.success,
						error:args.error
					});
				}

			};
			
			/**
			 * 登出
			 * @param args{authTicket:"", success:function(){} error:function(){}}
			 */
			this.logout = function (args) {
				if(_debugMode === true) {
					_webService.doGet({
						url:_appServiceHttpsUrl,
						params:{
							serviceType:"com.salama.easyapp.service.UserAuthService", 
							serviceMethod:"logout",
							appToken:_appAuthInfo.appToken, 
							authTicket:args.authTicket},
						success:args.success,
						error:args.error
					});				
				} else {
					_native.invoke({
						target: 'salama.userService', 
						method: 'logout', 
						params: null, 
						success: args.success,
						error:args.error
					});
				}
			};
			
			//these functions below for debugMode ------------------
			function setUserAuthInfoByXml(xml) {
				if(xml == undefined || xml == null || xml.length == 0) {
					_userAuthInfo.returnCode = "";
					_userAuthInfo.loginId = "";
					_userAuthInfo.userId = "";
					_userAuthInfo.authTicket = "";
					_userAuthInfo.expiringTime = 0;
				} else {
					var userAuthInfoTmp = simpleXml.xmlToVar(xml);
					_userAuthInfo.returnCode = (userAuthInfoTmp.returnCode == undefined?"":userAuthInfoTmp.returnCode);
					_userAuthInfo.loginId = (userAuthInfoTmp.loginId == undefined?"":userAuthInfoTmp.loginId);
					_userAuthInfo.userId = (userAuthInfoTmp.userId == undefined?"":userAuthInfoTmp.userId);
					_userAuthInfo.authTicket = (userAuthInfoTmp.authTicket == undefined?"":userAuthInfoTmp.authTicket);
					_userAuthInfo.expiringTime = (userAuthInfoTmp.expiringTime == undefined?0:userAuthInfoTmp.expiringTime);
				}
				
				storeUserAuthInfoXmlToStorage(xml);
			}
			
			function storeUserAuthInfoXmlToStorage(xml) {
				sessionStorage['salama.user.userAuthInfo'] = xml; 
			}
			function getUserAuthInfoXmlFromStorage() {
				return sessionStorage['salama.user.userAuthInfo'];
			}
		}
		
		//------------------------  cloud ----------------------------------------
		function SalamaCloud() {
			var _sql = new SQL();
			this.sql = _sql;
			
			var _file = new File();
			this.file = _file;
			
			function SQL() {
				/**
				 * 执行查询SQL
				 * @param args{sql:"",
				 * dataNodeName:"", 数据节点名。返回的XML格式为<List><数据节点名>....</数据节点名><数据节点名>....</数据节点名></List>的形式 
				 * success:function(result){} error:function(errorInfo){}}
				 */
				this.executeQuery = function(args) {
					if(_debugMode) {
						_webService.doGet({
							url:_appServiceHttpUrl,
							params:{
								serviceType:"com.salama.easyapp.service.SQLService", serviceMethod:"executeQuery",
								appToken:_appAuthInfo.appToken,
								authTicket:_user.userAuthInfo.authTicket,
								sql:args.sql,
								dataNodeName:(args.dataNodeName == undefined || args.dataNodeName == null)?"":args.dataNodeName
								},
							success:args.success,
							error:args.error
						});				
					} else {
						_native.invoke({
							target: 'salama.cloudService.sqlService', 
							method: 'executeQuery', 
							params: [args.sql], 
							success: args.success,
							error:args.error
						});
					}
				};
				
				/**
				 * 执行更新或删除SQL
				 * @param args{sql:"", success:function(result){} error:function(errorInfo){}}
				 */
				this.executeUpdate = function(args) {
					if(_debugMode) {
						_webService.doGet({
							url:_appServiceHttpUrl,
							params:{
								serviceType:"com.salama.easyapp.service.SQLService", serviceMethod:"executeUpdate",
								appToken:_appAuthInfo.appToken,
								authTicket:_user.userAuthInfo.authTicket,
								sql:args.sql
								},
							success:args.success,
							error:args.error
						});
					} else {
						_native.invoke({
							target: 'salama.cloudService.sqlService', 
							method: 'executeUpdate', 
							params: [args.sql], 
							success: args.success,
							error:args.error
						});
					}
				};
				
				/**
				 * 插入数据
				 * @param args: {
				 *  dataTable:表名 
				 *  data:可以是Object也可以是Xml, 
				 *  aclRestrictUserRead:指定拥有读权限的用户(多个用户idd逗号分割.该值未指定或空则仅仅数据创建者可以操作.'%'代表任何用户可以操作),
				 *  aclRestrictUserUpdate:指定拥有更新权限的用户,
				 *  aclRestrictUserDelete:指定拥有删除权限的用户,
				 *  success:function(result){} 
				 *  error:function(errorInfo){}
				 * }
				 */
				this.insertData = function(args) {
					var dataXml = null;
					if((typeof args.data).toLowerCase() == "object") {
						dataXml = simpleXml.varToXml(args.data, args.dataTable);
					} else {
						dataXml = args.data;
					}
					
					var aclRestrictUserRead = "";
					var aclRestrictUserUpdate = "";
					var aclRestrictUserDelete = "";
					if(args.aclRestrictUserRead != undefined && args.aclRestrictUserRead != null) {
						aclRestrictUserRead = args.aclRestrictUserRead; 
					}
					if(args.aclRestrictUserUpdate != undefined && args.aclRestrictUserUpdate != null) {
						aclRestrictUserUpdate = args.aclRestrictUserUpdate; 
					}
					if(args.aclRestrictUserDelete != undefined && args.aclRestrictUserDelete != null) {
						aclRestrictUserDelete = args.aclRestrictUserDelete; 
					}
					
					if(_debugMode) {
						_webService.doGet({
							url:_appServiceHttpUrl,
							params:{
								serviceType:"com.salama.easyapp.service.SQLService", serviceMethod:"insertData",
								appToken:_appAuthInfo.appToken,
								authTicket:_user.userAuthInfo.authTicket,
								dataTable:args.dataTable,
								dataXml:dataXml,
								aclRestrictUserRead:aclRestrictUserRead,
								aclRestrictUserRead:aclRestrictUserUpdate,
								aclRestrictUserRead:aclRestrictUserDelete
								},
							success:args.success,
							error:args.error
						});
					} else {
						_native.invoke({
							target: 'salama.cloudService.sqlService', 
							method: 'insertData', 
							params: [args.dataTable, dataXml, aclRestrictUserRead, aclRestrictUserUpdate, aclRestrictUserDelete], 
							success: args.success,
							error:args.error
						});
					}
				};
				
			}
			
			function File() {
				/**
				 * 下载文件
				 * @param args{
				 * 	fileId:"", 
				 *  saveToFilePath:"", 该参数为可选，若未指定，则存放入/html/res/下。 
				 *  success:function(result){} error:function(errorInfo){}}
				 */
				this.downloadByFileId = function (args) {
					if(args.saveToFilePath == undefined || args.saveToFilePath == null) {
						_native.invoke({
							target:"salama.cloudService.fileService", 
							method:"downloadByFileId", 
							params: [args.fileId], 
							success: args.success, 
							error: args.error
						});
					} else {
						_native.invoke({
							target:"salama.cloudService.fileService", 
							method:"downloadByFileId", 
							params: [args.fileId, args.saveToFilePath], 
							success: args.success, 
							error: args.error
						});
					}
				};
				
				/**
				 * 添加下载后台任务
				 * @param args{
				 * 	fileId:"", 文件ID 
				 *  saveToFilePath:"", 该参数为可选，若未指定，则存放入/html/res/下
				 *  notificationName: "", 通知名称，任务完成后通知用的通知名
				 *  }
				 */
				this.addDownloadTaskWithFileId = function(args) {
					if(args.saveToFilePath == undefined || args.saveToFilePath == null) {
						_native.invoke({
							target:"salama.cloudService.fileService", 
							method:"addDownloadTaskWithFileId", 
							params: [args.fileId, args.notificationName], 
							success: args.success, 
							error: args.error
						});
					} else {
						_native.invoke({
							target:"salama.cloudService.fileService", 
							method:"addDownloadTaskWithFileId", 
							params: [args.fileId, args.saveToFilePath, args.notificationName], 
							success: args.success, 
							error: args.error
						});
					}
				};
				
				/**
				 * 添加文件(上传)
				 * @param args{filePath:"",
				 * aclRestrictUserRead, 若未指定，则作为""处理。
				 * aclRestrictUserUpdate, 若未指定，则作为""处理。
				 * aclRestrictUserDelete,  若未指定，则作为""处理。
				 * success:function(result){} error:function(errorInfo){}}
				 */
				this.addFile = function (args) {
					var aclRestrictUserRead = "";
					var aclRestrictUserUpdate = "";
					var aclRestrictUserDelete = "";
					if(args.aclRestrictUserRead != undefined && args.aclRestrictUserRead != null) {
						aclRestrictUserRead = args.aclRestrictUserRead; 
					}
					if(args.aclRestrictUserUpdate != undefined && args.aclRestrictUserUpdate != null) {
						aclRestrictUserUpdate = args.aclRestrictUserUpdate; 
					}
					if(args.aclRestrictUserDelete != undefined && args.aclRestrictUserDelete != null) {
						aclRestrictUserDelete = args.aclRestrictUserDelete; 
					}
					
					_native.invoke({
						target:"salama.cloudService.fileService", 
						method:"addFile", 
						params: [args.filePath, aclRestrictUserRead, aclRestrictUserUpdate, aclRestrictUserDelete], 
						success: args.success, 
						error: args.error
					});
				};
				
				/**
				 * 变更文件(上传)
				 * @param args{fileId:"", 
				 * filePath:"",  
				 * success:function(result){} error:function(errorInfo){}}
				 */
				this.updateByFileId = function (args) {
					_native.invoke({
						target:"salama.cloudService.fileService", 
						method:"updateByFileId", 
						params: [args.fileId, args.filePath], 
						success: args.success, 
						error: args.error
					});
				};
				
				/**
				 * 删除文件
				 * @param args{fileId:"", 
				 * success:function(result){} error:function(errorInfo){}}
				 */
				this.deleteByFileId = function (args) {
					_native.invoke({
						target:"salama.cloudService.fileService", 
						method:"deleteByFileId", 
						params: [args.fileId], 
						success: args.success, 
						error: args.error
					});
				};
			}
			
		}
		

		//------------------------  native ----------------------------------------
		function SalamaNative() {
			var _successPID = 0;
			var _errorPID = 0;

			var _invokeImp = function(args) {
				if(args.length != undefined) {
					var cmdArray = new Array();
					for(var i = 0; i < args.length; i++) {
						cmdArray.push(handleSuccessErrorFunction(args[i]));
					}
					
					nativeService.invoke(cmdArray);
				} else {
					nativeService.invoke(handleSuccessErrorFunction(args));
				}
			};
			
			function handleSuccessErrorFunction(args) {
				if((args.success != undefined) && (typeof args.success) === "function") {
					var successFuncName = null;
					var errorFuncName = null;
					var context;
					
					if((args.success != undefined) && (args.success != null)) {
						successFuncName = "salama_native_invoke_suc_" + String(++_successPID);
						window[successFuncName] = function (data) {
							delete window[successFuncName];
							args.success.call(context, data);
						};
					}
					if((args.error != undefined) && (args.error != null)) {
						errorFuncName = "salama_native_invoke_err_" + String(++_errorPID);
						window[errorFuncName] = function (data) {
							delete window[errorFuncName];
							args.error.call(context, data);
						};
					}
					
					return {
						target:args.target, 
						method:args.method, 
						params: args.params, 
						success: successFuncName, 
						error: errorFuncName
					}
					;
				} else {
					return args;
				}
			}
			
			var _invoke = function(args, isSync) {
				//建议不要使用同步调用方式，经过测试，Async.js的series()方法在某些情况下，无法完成同步等待callback完成的目的。可能因为Browser里的JS为单线程运行，用变通的方法并不能改变此状况。
				if(args.length == undefined
					&& (
					(isSync != undefined && isSync == true) 
						|| ((args.success == undefined || args.success == null)
							&& (args.notification == undefined || args.notification == null))
					)
				) {
					var returnVal = null;
					
		            async.series([
		                function(callback){
							_invokeImp({
								target: args.target, 
								method: args.method, 
								params: args.params, 
								success: function(result){
									returnVal = result;
									callback(null);
								}
							});
		                }
		            ],
		            function(err, results){
		            });
					 
		           return returnVal;
				} else {
					_invokeImp(args);
				}
				
			}
			
			this.invoke = _invoke;
			
			var _file = new NativeFile();
			this.file = _file;
			
			var _sql = new NativeSql();
			this.sql = _sql;
			
			function NativeFile() {
				/**
				 * 取得实际物理存储上的路径
				 * @param args {virtualPath:"", success:function(){}, error:function(){}} or [virtualPath]
				 * @return real path of virtualPath
				 */
				this.getRealPathByVirtualPath = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.virtualPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'getRealPathByVirtualPath', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 文件是否存在
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return 1:yes 0:no
				 */
				this.isExistsFile = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'isExistsFile', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 路径是否存在，并且是否目录
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return 1:yes 0:no
				 */
				this.isExistsDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'isExistsDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 取得临时文件目录
				 * @param args {success:function(){}, error:function(){}} or null
				 * @return temp dir path
				 */
				this.getTempDirPath = function(args) {
					var isSync = false;
					if(args == undefined || args == null || args.length != undefined) {
						isSync = true;
					} else {
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'getTempDirPath', 
						params: null, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				
				/**
				 * 文件拷贝
				 * @param args {from:"", to:"", success:function(){}, error:function(){}} or [from, to]
				 * @return value of parameter "to"
				 */
				this.copyFileFrom = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.from, args.to];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}
					
					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'copyFileFrom', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
					
				};
				

				/**
				 * 文件移动
				 * @param args {from:"", to:"", success:function(){}, error:function(){}} or [from, to]
				 * @return value of parameter "to"
				 */
				this.moveFileFrom = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.from, args.to];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}
					
					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'moveFileFrom', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
					
				};

				/**
				 * 文本方式读取文件内容(utf-8编码方式)
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return text content of filePath
				 */
				this.readAllText = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'readAllText', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 写入文本文件(文件不存在的话，被创建。文件存在的话，原内容被冲掉)(utf-8编码方式)
				 * @param args {filePath:"", text:"", success:function(){}, error:function(){}} or [filePath, text]
				 * @return filePath
				 */
				this.writeTextToFile = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath, args.text];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'writeTextToFile', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
					
				};

				/**
				 * 追加写入文本文件(文件不存在的话，被创建。文件存在的话，在原内容末尾追加)
				 * @param args {filePath:"", text:""} or [filePath, text]
				 * @return filePath
				 */
				this.appendTextToFile = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath, args.text];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'appendTextToFile', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				
				/**
				 * 统计目录所有文件用量(单位byte)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return volumne(bytes) of dir
				 */
				this.calculateVolumeOfDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'calculateVolumeOfDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 列出目录下所有文件名(不递归)
				 * @param args {dirPath:"", isIncludeSubDir:true, success:function(){}, error:function(){}} or [dirPath, isIncludeSubDir]
				 * @return xml of fileNames list
				 */
				this.listFileNamesInDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath, args.isIncludeSubDir==true?1:0];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = [args[0], args[1]==true?1:0];
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFileNamesInDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);

				};

				/**
				 * 列出目录下所有文件路径(不递归)
				 * @param args {dirPath:"", isIncludeSubDir:true, success:function(){}, error:function(){}} or [dirPath, isIncludeSubDir]
				 * @return xml of file path list
				 */
				this.listFilesInDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath, args.isIncludeSubDir==true?1:0];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = [args[0], args[1]==true?1:0];
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFilesInDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 列出目录下所有文件路径(递归)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return xml of file path list
				 */
				this.listFilesRecursivelyInDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFilesRecursivelyInDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 删除文件
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return filePath
				 */
				this.deleteFile = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'deleteFile', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 删除目录(递归)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return filePath
				 */
				this.deleteDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'deleteDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 创建目录(可以创建多层目录)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return dirPath
				 */
				this.mkdir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'mkdir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 压缩文件
				 * @param args {filePath:"", zipPath:"", success:function(){}, error:function(){}} or [filePath, zipPath]
				 * @return zipPath
				 */
				this.compressZipFromFile = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.filePath, args.zipPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'compressZipFromFile', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};


				/**
				 * 压缩文件
				 * @param args {dirPath:"", zipPath:"", success:function(){}, error:function(){}} or [dirPath, zipPath]
				 * @return zipPath
				 */
				this.compressZipFromDir = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dirPath, args.zipPath];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'compressZipFromDir', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};

				/**
				 * 解压缩文件
				 * @param args {zipPath:"", toDir:"", success:function(){}, error:function(){}} or [zipPath, toDir]
				 * @return zipPath
				 */
				this.decompressZip = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.zipPath, args.toDir];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'decompressZip', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
					
				};

			} // end of function NativeFile 
			
			function NativeSql() {
				/**
				 * 建表(如果表已经存在，则不做任何事)
				 * @param args {
				 * 	tableDesc:{tableName:"", primaryKeys:"", colDescList:[{colName:"", colType},{colName:"", colType},...]}, 
				 * success:function(){}, error:function(){}} 
				 * or [{tableName:"", primaryKeys:"", colDescList:[{colName:"", colType},{colName:"", colType},...]}]
				 * @return tableName
				 */
				this.createTable = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [{TableDesc:args.tableDesc}];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = [{TableDesc:args[0]}];;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'createTable', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 执行查询语句
				 * @param args {sql:"", dataNodeName:"", success:function(){}, error:function(){}} or [sql, dataNodeName]
				 * @return 查询结果(XML格式)
				 */
				this.executeQuery = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.sql, args.dataNodeName];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'executeQuery', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 执行更新语句(update或delete)
				 * @param args {sql:"", success:function(){}, error:function(){}} or [sql]
				 * @return 1:成功 0:失败
				 */
				this.executeUpdate = function(args) {
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.sql];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = args;
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'executeUpdate', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
				/**
				 * 插入数据
				 * @param args {dataTable:"", data:"", success:function(){}, error:function(){}} or [dataTable, dataXml]
				 * @return dataXml 数据XML
				 */
				this.insertData = function(args) {
					var dataXml = null;
					if((typeof args.data).toLowerCase() == "object") {
						dataXml = simpleXml.varToXml(args.data, args.dataTable);
					} else {
						dataXml = args.data;
					}
					
					var params;
					var isSync = false;
					if(args.length == undefined) {
						params = [args.dataTable, dataXml];
						if(args.success == undefined || args.success == null) {
							isSync = true;
						}
					} else {
						params = [args[0], dataXml];
						isSync = true;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'insertData', 
						params: params, 
						success: args.success,
						error: args.error
					}, isSync);
				};
				
			} // end of function NativeSql
		}


	}
	} catch(e) {
		alert("js error:" + e);
	}
	
	//Expose
	window.salama = salama;
	
})(window);
