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
function EasyJsTextEncoder(metaCharArray, encodeStrArray) {
//		var MetaChars = new Array('<', '>', '&', '\'', '"' );
//		var EncodeStrs = new Array("&lt;", "&gt;", "&amp;", "&apos;", "&quot;");
		var MetaChars = metaCharArray;
		var EncodeStrs = encodeStrArray;
		var encodePrefixChr = encodeStrArray[0].charAt(0);

		/**
		 * XML特殊字符编码
		 */
		this.encode = function(content) {
			return encodeText(content);
		};

		/**
		 * XML特殊字符转码
		 */
		this.decode = function(content) {
			return decodeText(content);
		};

		function encodeText(content)
		{
			var encodedContent = '';
		    if(content == null) return content;

		    var i = 0;
		    var indexOfMeta = 0;
		    for (; i < content.length; i++)
		    {
		        indexOfMeta = 0;
		        for (; indexOfMeta < MetaChars.length; indexOfMeta++)
		        {
		            if (content.charAt(i) == MetaChars[indexOfMeta])
		            {
		                break;
		            }
		        }

		        if (indexOfMeta < MetaChars.length)
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

		function decodeText(content)
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
		        //if (content.charAt(i) == '&')
		        if (content.charAt(i) == encodePrefixChr)
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
}	

