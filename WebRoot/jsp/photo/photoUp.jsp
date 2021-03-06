<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@taglib uri="/struts-tags" prefix="s"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
	<head>
	<title>上传新照片</title>
		<base href="<s:text name="basePath"/>">
		<link rel="stylesheet" href="css/photo/photoUp.css" type="text/css"></link>
		<script src="js/jquery/jquery-1.7.2.min.js" type="text/javascript" charset="utf-8"></script>
		<script src="js/photo/photoUpload.js" type="text/javascript" charset="utf-8"></script>
		
		<script src="js/photo/editor_all.js" type="text/javascript" charset="utf-8"></script>
		<script src="js/photo/internal.js" type="text/javascript" charset="utf-8"></script>
	</head>
<body>
	<div class="photo-upload-card">
		<div class="album-group-list">
			<div class="album-group-title">
				请选择相册
			</div>
			<div class="album-list-box">
				<%--遍历相册分组  --%>
				<s:iterator value="albumGroupList">
				<div class="album-group" id="group<s:property value="albumGroupId"/>">
					<s:property value="albumGroupId"/>
					<s:property value="albumGroupName"/>
				</div>
				<div class="album-box" id="albumgroup<s:property value="albumGroupId"/>">
					<s:iterator value="albumList">
					<s:if test="ownAlbumGroupId == albumGroupId">
						<div class="album" id="<s:property value="albumId"/>">
							<div class="album-cover">
								<s:iterator value="albumCoverList">
								<s:if test="albumId == ownAlbumId">
									<img src="<s:text name="kanPath"/><s:property value="#session.keeno"/>/photo_thum/<s:property value="photoName"/>" alt="无法显示时的替代文字" />		
								</s:if>
								</s:iterator>
							</div>
							<div class="album-name">
								<s:property value="albumName"/>	
							</div>
						</div>
					</s:if>
					</s:iterator>
				</div>
				</s:iterator>
			</div>
		</div>
		<div class="photo-upload-box">
			<input type="hidden" name="albumId" id="albumId" value=""/>
			<div id="flashContainer" class="flash-container"></div>
			<div class="photo-upload-tool">
				<input type="button" id="upload" value="开始上传" style="display: none"/>
			</div>
		</div>
		<input type="hidden" id="uploadDate" value="<s:property value="uploadDate"/>"/>
		<input type="hidden" id="uploadTime" value="<s:property value="uploadTime"/>"/>
		<script src="js/photo/tangram.js" type="text/javascript" charset="utf-8"></script>
		<script src="js/photo/image.js" type="text/javascript" charset="utf-8"></script>
		<script type="text/javascript">
			//全局变量
	        var imageUrls = [],          //用于保存从服务器返回的图片信息数组
	            selectedImageCount = 0;  //当前已选择的但未上传的图片数量
	        editor.setOpt({
	            imageFieldName:"upfile",
	            compressSide:0,
	            maxImageSideLength:900
	        });
	        utils.domReady(function(){
	        	var flashOptions = {	 //创建Flash相关的参数集合
	        		container:"flashContainer",                                                    	//flash容器id
			        url: "uploadimg",                                           					//上传处理页面的url地址
			        //url:"jsp/imageUp.jsp",
			        ext:'{"param1":"value1", "param2":"value2"}',                                 	//可向服务器提交的自定义参数列表
			        fileType:'{"description":"图片", "extension":"*.gif;*.jpeg;*.png;*.jpg"}',     	//上传文件格式限制
			        flashUrl:'flash/photo/imageUploader.swf',						//上传用的flash组件地址
			        width:770,          				//flash的宽度
			        height:570,         				//flash的高度
			        gridWidth: 140,     				// 每一个预览图片所占的宽度
			        gridHeight: 140,    				// 每一个预览图片所占的高度
			        picWidth: 120,      				// 单张预览图片的宽度
			        picHeight: 120,     				// 单张预览图片的高度
			        uploadDataFieldName: "uploadFieldName",    // POST请求中图片数据的key
			        //uploadDataFieldName:editor.options.imageFieldName,    // POST请求中图片数据的key
			        picDescFieldName:'photoDescription',      	// POST请求中图片描述的key
			         //picDescFieldName:'pictitle',
			        maxSize:4,                         	// 文件的最大体积,单位M
			        compressSize:2,                   	// 上传前如果图片体积超过该值，会先压缩,单位M
			        maxNum: 300,                         	// 单次最大可上传多少个文件
			        backgroundUrl:'',                 	// flash界面的背景图片,留空默认
			        listBackgroundUrl:'',            	// 单个预览框背景，留空默认
			        buttonUrl:'',                     	// 上传按钮背景，留空默认
			        //compressSide:2,                 	//等比压缩的基准，0为按照最长边，1为按照宽度，2为按照高度
			        //compressLength:         			//能接受的最大边长，超过该值Flash会自动等比压缩
			    };
			  //回调函数集合，支持传递函数名的字符串、函数句柄以及函数本身三种类型
            var callbacks = {
            		 // 选择文件的回调
                    selectFileCallback: function(selectFiles){
                        utils.each(selectFiles,function(file){
                            var tmp = {};
                            tmp.id = file.index;
                            tmp.data = {};
                            postConfig.push(tmp);
                        });
                        selectedImageCount += selectFiles.length;
                        if(selectedImageCount) baidu.g("upload").style.display = "";
                        dialog.buttons[0].setDisabled(true); //初始化时置灰确定按钮
                    },
                    // 删除文件的回调
                    deleteFileCallback: function(delFiles){
                        for(var i = 0,len = delFiles.length;i<len;i++){
                            var index = delFiles[i].index;
                            postConfig.splice(index,1);
                        }
                        selectedImageCount -= delFiles.length;
                        if (!selectedImageCount) {
                            baidu.g("upload").style.display = "none";
                            dialog.buttons[0].setDisabled(false);         //没有选择图片时重新点亮按钮
                        }
                    },

                    // 单个文件上传完成的回调
                    uploadCompleteCallback: function(data){
                        try{
                            var info = eval("(" + data.info + ")");
                            info && imageUrls.push(info);
                            selectedImageCount--;
                        }catch(e){}

                    },
                    // 单个文件上传失败的回调,
                    uploadErrorCallback: function (data){
                        if(!data.info){
                            alert(lang.netError);
                        }
                        //console && console.log(data);
                    },
                    // 全部上传完成时的回调
                    allCompleteCallback: function(){
                        window.location.href = "photoUpFinish.html?ownAlbumId="+baidu.g("albumId").value+"&uploadDate="+baidu.g("uploadDate").value+"&uploadTime="+baidu.g("uploadTime").value;
                    },
                    // 文件超出限制的最大体积时的回调
                    //exceedFileCallback: 'exceedFileCallback',
                    // 开始上传某个文件时的回调
                    startUploadCallback: function(){
                        var config = postConfig.shift();
                        //也可以在这里更改
                        //if(config.id==2){ //设置第三张图片的对应参数
                        //     config.data={"myParam":"value"}
                        // }
                        flashObj.addCustomizedParams(config.id,config.data);
                    }
                };
            	imageUploader.init(flashOptions,callbacks);
            	$G("upload").onclick = function () {
	                /**
	                 * 接口imageUploader.setPostParams()可以在提交时设置本次上传提交的参数（包括所有图片）
	                 * 参数为json对象{"key1":"value1","key2":"value2"}，其中key即为向后台post提交的name，value即为值。
	                 * 其中有一个特殊的保留key值为action，若设置，可以更改本次提交的处理地址
	                 */
	                 var postParams = {
	                    "belongAlbumId":baidu.g("albumId").value,
	                    "uploadDate":baidu.g("uploadDate").value,
	                    "uploadTime":baidu.g("uploadTime").value
	                };
	                 imageUploader.setPostParams(postParams);
	                 flashObj.upload();
	                 this.style.display = "none";
	                 //$G("savePath").parentNode.style.display = "none";
	            };
	        });
		</script>
	</div>
</body>
</html>
