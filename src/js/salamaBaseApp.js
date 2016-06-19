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
	var _salama = new Salama();

	function Salama() {
    try {
        //default value
		var _debugMode = nativeService.getDebugMode();

		this.sqlUtil = new SalamaSqlUtil();

		this.native = new SalamaNative();
        var _native = this.native;

		this.webService = new SalamaWebService();

		this.setDebugMode = function (isDebug) {
            _debugMode = isDebug;
        };

        this.log = function (msg) {
            _native.invoke({
                target: "thisView",
                method: "log",
                params: [msg],
            });
        };

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
			 * @param args {url:"", params, success, error}
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


		//------------------------  native ----------------------------------------
        /**
         * all these return value is dispatched through the argument of success function
         */
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
			
			var _invoke = function(args) {
                _invokeImp(args);
			};
			
			this.invoke = _invoke;
			
			var _file = new NativeFile();
			this.file = _file;
			
			var _sql = new NativeSql();
			this.sql = _sql;
			
			function NativeFile() {
				/**
				 * 取得实际物理存储上的路径
				 * @param args {virtualPath:"", success:function(realPath){}, error:function(){}} or [virtualPath]
				 * @return real path of virtualPath
				 */
				this.getRealPathByVirtualPath = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.virtualPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'getRealPathByVirtualPath', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 文件是否存在
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return 1:yes 0:no
				 */
				this.isExistsFile = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'isExistsFile', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 路径是否存在，并且是否目录
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return 1:yes 0:no
				 */
				this.isExistsDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'isExistsDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 取得临时文件目录
				 * @param args {success:function(){}, error:function(){}} or null
				 * @return temp dir path
				 */
				this.getTempDirPath = function(args) {
					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'getTempDirPath', 
						params: null, 
						success: args.success,
						error: args.error
					});
				};
				
				
				/**
				 * 文件拷贝
				 * @param args {from:"", to:"", success:function(){}, error:function(){}} or [from, to]
				 * @return value of parameter "to"
				 */
				this.copyFileFrom = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.from, args.to];
					} else {
						params = args;
					}
					
					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'copyFileFrom', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				

				/**
				 * 文件移动
				 * @param args {from:"", to:"", success:function(){}, error:function(){}} or [from, to]
				 * @return value of parameter "to"
				 */
				this.moveFileFrom = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.from, args.to];
					} else {
						params = args;
					}
					
					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'moveFileFrom', 
						params: params, 
						success: args.success,
						error: args.error
					});
					
				};

				/**
				 * 文本方式读取文件内容(utf-8编码方式)
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return text content of filePath
				 */
				this.readAllText = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'readAllText', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 写入文本文件(文件不存在的话，被创建。文件存在的话，原内容被冲掉)(utf-8编码方式)
				 * @param args {filePath:"", text:"", success:function(){}, error:function(){}} or [filePath, text]
				 * @return filePath
				 */
				this.writeTextToFile = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath, args.text];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'writeTextToFile', 
						params: params, 
						success: args.success,
						error: args.error
					});
					
				};

				/**
				 * 追加写入文本文件(文件不存在的话，被创建。文件存在的话，在原内容末尾追加)
				 * @param args {filePath:"", text:""} or [filePath, text]
				 * @return filePath
				 */
				this.appendTextToFile = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath, args.text];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'appendTextToFile', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				
				/**
				 * 统计目录所有文件用量(单位byte)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return volumne(bytes) of dir
				 */
				this.calculateVolumeOfDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'calculateVolumeOfDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 列出目录下所有文件名(不递归)
				 * @param args {dirPath:"", isIncludeSubDir:true, success:function(){}, error:function(){}} or [dirPath, isIncludeSubDir]
				 * @return xml of fileNames list
				 */
				this.listFileNamesInDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath, args.isIncludeSubDir==true?1:0];
					} else {
						params = [args[0], args[1]==true?1:0];
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFileNamesInDir', 
						params: params, 
						success: args.success,
						error: args.error
					});

				};

				/**
				 * 列出目录下所有文件路径(不递归)
				 * @param args {dirPath:"", isIncludeSubDir:true, success:function(){}, error:function(){}} or [dirPath, isIncludeSubDir]
				 * @return xml of file path list
				 */
				this.listFilesInDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath, args.isIncludeSubDir==true?1:0];
					} else {
						params = [args[0], args[1]==true?1:0];
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFilesInDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 列出目录下所有文件路径(递归)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return xml of file path list
				 */
				this.listFilesRecursivelyInDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'listFilesRecursivelyInDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 删除文件
				 * @param args {filePath:"", success:function(){}, error:function(){}} or [filePath]
				 * @return filePath
				 */
				this.deleteFile = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'deleteFile', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 删除目录(递归)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return filePath
				 */
				this.deleteDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'deleteDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 创建目录(可以创建多层目录)
				 * @param args {dirPath:"", success:function(){}, error:function(){}} or [dirPath]
				 * @return dirPath
				 */
				this.mkdir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'mkdir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 压缩文件
				 * @param args {filePath:"", zipPath:"", success:function(){}, error:function(){}} or [filePath, zipPath]
				 * @return zipPath
				 */
				this.compressZipFromFile = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.filePath, args.zipPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'compressZipFromFile', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};


				/**
				 * 压缩文件
				 * @param args {dirPath:"", zipPath:"", success:function(){}, error:function(){}} or [dirPath, zipPath]
				 * @return zipPath
				 */
				this.compressZipFromDir = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.dirPath, args.zipPath];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'compressZipFromDir', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};

				/**
				 * 解压缩文件
				 * @param args {zipPath:"", toDir:"", success:function(){}, error:function(){}} or [zipPath, toDir]
				 * @return zipPath
				 */
				this.decompressZip = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.zipPath, args.toDir];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.fileService', 
						method: 'decompressZip', 
						params: params, 
						success: args.success,
						error: args.error
					});
					
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
					if(args.length == undefined) {
						params = [{TableDesc:args.tableDesc}];
					} else {
						params = [{TableDesc:args[0]}];;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'createTable', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 执行查询语句
				 * @param args {sql:"", dataNodeName:"", success:function(){}, error:function(){}} or [sql, dataNodeName]
				 * @return 查询结果(XML格式)
				 */
				this.executeQuery = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.sql, args.dataNodeName];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'executeQuery', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
				/**
				 * 执行更新语句(update或delete)
				 * @param args {sql:"", success:function(){}, error:function(){}} or [sql]
				 * @return 1:成功 0:失败
				 */
				this.executeUpdate = function(args) {
					var params;
					if(args.length == undefined) {
						params = [args.sql];
					} else {
						params = args;
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'executeUpdate', 
						params: params, 
						success: args.success,
						error: args.error
					});
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
					if(args.length == undefined) {
						params = [args.dataTable, dataXml];
					} else {
						params = [args[0], dataXml];
					}

					return _invoke({
						target: 'salama.nativeService.sqlService', 
						method: 'insertData', 
						params: params, 
						success: args.success,
						error: args.error
					});
				};
				
			} // end of function NativeSql
		}


    } catch(e) {
        alert("js error:" + e);
    }
	}

	//Expose
	window.salama = _salama;
	
})(window);
