<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/include/taglibs.jsp"%>
<jsp:useBean id="now" class="java.util.Date" />
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
<title>koscom</title>
<%@ include file="/WEB-INF/include/headComm.jsp"%>

<script type="text/javascript">
$(document).ready(function() {
	var isScrap = "<%=(String)session.getAttribute("AutoScrap")%>"
	
	//로그인 한 후 한번만 실행
	if(isScrap == "true" && userAgent == "Android")	{
		//문자내역 조회 정보
		var smsStartDate = '<c:out value="${smsStartDate}" escapeXml="false"/>';
		var smsInclude = '<c:out value="${smsInclude}" escapeXml="false"/>';
		var smsExclude = '<c:out value="${smsExclude}" escapeXml="false"/>';

		window.Android.getSmsList(smsStartDate, smsInclude, smsExclude);

		var site = '<c:out value="${site}" escapeXml="false"/>';
		//실 가동은 스크래핑 제외(추후 반영)
		if(site != "REAL")	{
			//은행 스크래핑 내역
			var bankInfo = '<c:out value="${autoScrapBankInfo}" escapeXml="false"/>';
			//카드 스크래핑 내역
			var cardInfo = '<c:out value="${autoScrapCardInfo}" escapeXml="false"/>';
			//국세청 스크래핑 내역
			var ntsInfo = '<c:out value="${autoScrapNTSInfo}" escapeXml="false"/>';
			
			//스크래핑 해야할 내역이 한가지라도 있을 경우에만 호출
			if(bankInfo.length + cardInfo.length + ntsInfo.length > 0)	{
				window.Android.startAutoScrap("bank", bankInfo);
				window.Android.startAutoScrap("card", cardInfo);
				window.Android.startAutoScrap("nts", ntsInfo);
			}
		}
		<%session.setAttribute("AutoScrap", "false");%>
	}
});
$(function(){
	
	if(userAgent == "Android") {
		window.Android.setEndApp('Y');
		
		// 스플래시 OFF
		//TODO 앱 정상배포시 try-catch 제거하고 스크립트만 호출해야함
		try {
			window.Android.splash("N");
		} catch(e) {
			console.log(e);
		}
		
		//FCM_TOKEN 갱신
		window.Android.setNoPerson('${noPerson}', getCookie('hp'));
	}
	else if(userAgent == "iOS")
	{
		Jockey.send("splashView",{
			yn_splash : "N"
		});
		
		//FCM_TOKEN 갱신
		Jockey.send("setNoPerson",{
			noPerson : '${noPerson}',
			phNum : getCookie('hp')
		});
	}	
 
	var path = document.getElementById('gauge'),
		leng = path.getTotalLength(),
		title = $(".grade"),
		gauge = $("#gauge");
	
	gauge.css({
		"stroke-dasharray": leng,
		"stroke-dashoffset": leng * 2
	});
	
	function creditGrade(n) {
		var level = n * 10,
			dasharray = (1 - 0.1) + (level / 100),
			progress = leng * dasharray;

		if ( n !== "1" ) {
			progress = progress - 2;
		}
		
		title.html(n);
		gauge.stop().queue(function(){
			$(this).animate({
				"stroke-dashoffset": progress
			}, 1000, "linear").dequeue();
		});
	}
	
	//등급 셋팅
	creditGrade(Number("${baseInfo.grade_credit}"));
	
});

//신용등급상세로 이동
function goFrameCreditInfoDetail(detailTabNm){
	document.frmDetail.detailTabNm.value = detailTabNm;
	document.frmDetail.action = "<c:url value='/m/credit/frameCreditInfoDetail.crz'/>";
	document.frmDetail.submit();
}

//알림 이동
function goNoti() { 
	document.frmStep.action="/m/customercenter/frameCustomerNotification.crz";
	document.frmStep.method="post"; 
	document.frmStep.submit(); 
}
//신용점수 올리기 이동
function goCreditRaise() { 
	document.frmStep.action="/m/credit/frameCreditRaise.crz";
	document.frmStep.method="post"; 
	document.frmStep.submit(); 
}

//공유관리 이동
function goPersonShareInfo(){
	document.frmStep.action="/m/customercenter/frameShareInfoSummary.crz";
	document.frmStep.method="post"; 
	document.frmStep.submit(); 
}

//스마트리포트 이동
function goSmartReportDetail(){
	document.frmStep.action="/m/credit/frameCreditSmartReportInfo.crz"; 
	document.frmStep.method="post"; 
	document.frmStep.submit(); 
}

</script>
</head>
<body>
<div id="wrapper">
	<!-- Header -->
	<header id="header">
		<div class="input-group">
			<div class="input-group-btn blind">
				<button type="button" class="ui-nav nav-back" onclick="goGoodsMain();">뒤로가기</button>
			</div>
			<h1>신용관리</h1>
			<div class="g-menu">
				<button type="button" class="ico ico-notilist" onclick="goNoti();">알림내역</button>
				<button type="button" class="btn btn-gmenu" onclick="goPersonShareInfo();">정보공유</button>
			</div>
		</div>
	</header>
	<!-- Content -->
	<section id="content"> 
		<div class="block-fill credit-block">
			<div class="block-container">
				<!-- 차트로 대체 예정 -->
				<div class="my-credit-title">		
					<p class="date"><fmt:formatDate value="${now}" pattern="yyyy.MM.dd" /></p>
					<%--
					<h3 class="h3">나의 신용정보</h3>
					<p class="date"><fmt:formatDate value="${now}" pattern="yyyy.MM.dd" /></p>
					--%>
				</div>
				<div class="credit-grade">	
					<svg id="svg" viewBox="40 125 320 150">
						<defs>
							<linearGradient id="rainbow">
								<stop class="color1" offset="0%" />
								<stop class="color2" offset="10%" />
								<stop class="color3" offset="20%" />
								<stop class="color4" offset="30%" />
								<stop class="color5" offset="40%" />
								<stop class="color6" offset="50%" />
								<stop class="color6" offset="60%" />
								<stop class="color7" offset="70%" />
								<stop class="color8" offset="80%" />
								<stop class="color9" offset="90%" />
								<stop class="color10" offset="100%" />
							</linearGradient>
						</defs>
						<text x="200" y="230" class="grade-h" text-anchor="middle">
							<tspan x="185" y="235" class="grade"></tspan>
							<tspan x="220" y="">등급</tspan>			
						</text>
						<text x="200" y="266" class="grade-ranking" text-anchor="middle">
							<tspan x="" y="" class="ranking"><c:out value="${baseInfo.rating_credit}"/>
							
							<tspan class="score">
								<c:choose>
								<c:when test="${baseInfo.rating_diff gt 0}">
								<tspan class="score-up">▲</tspan> <c:out value="${baseInfo.rating_diff}"/>
								</c:when>
								<c:when test="${baseInfo.rating_diff lt 0}">
								<tspan class="score-down">▼</tspan><c:out value="${fn:substring(baseInfo.rating_diff,1,fn:length(baseInfo.rating_diff))}"/>
								</c:when>
								<c:otherwise>
								<tspan class="score-same">-</tspan>
								</c:otherwise>
								</c:choose>
							</tspan>
							<tspan class="text-slash">|</tspan> 상위 <c:out value="${baseInfo.percentage}"/>%</tspan>
						</text>		
						<path class="gauge-bg" fill="#C2C9D2" d="M327,268.494h-28v-1.988c0-54.587-44.411-98.997-99-98.997s-99,44.41-99,98.997v1.988H73v-1.988
							c0-70.026,56.972-126.997,127-126.997c70.028,0,127,56.97,127,126.997V268.494z"/>
						<path id="gauge" fill="none" stroke="#c2c9d2" stroke-width="26" stroke-miterlimit="10" d="M87,267.506v-1c0-62.404,50.591-112.997,113-112.997
							s113,50.592,113,112.997v1"/>
						<path class="marking" fill="#283593" d="M200,138.495c-70.58,0-128,57.42-128,128v3.012h30v-3.012c0-54.037,43.962-98,98-98
							c54.037,0,98,43.962,98,98v3.012h30v-3.012C328,195.915,270.579,138.495,200,138.495z M94,267.506H74v-2h20V267.506z
							 M94.095,261.947l-14.147-0.741l0.104-1.998l14.147,0.741L94.095,261.947z M94.479,256.41l-13.93-1.465l0.209-1.988l13.93,1.465
							L94.479,256.41z M95.151,250.902l-13.838-2.192l0.313-1.975l13.838,2.192L95.151,250.902z M96.111,245.437l-13.707-2.914
							l0.416-1.957l13.707,2.914L96.111,245.437z M97.356,240.029l-13.615-3.649l0.518-1.932l13.615,3.649L97.356,240.029z
							 M98.879,234.701l-19.021-6.181l0.618-1.902l19.021,6.181L98.879,234.701z M100.686,229.446l-13.073-5.021l0.717-1.867l13.073,5.021
							L100.686,229.446z M102.761,224.298l-12.785-5.694l0.813-1.826l12.785,5.694L102.761,224.298z M105.104,219.268l-12.461-6.351
							l0.908-1.781l12.461,6.351L105.104,219.268z M107.705,214.366l-12.1-6.992l1.001-1.732l12.1,6.992L107.705,214.366z M110.56,209.608
							l-11.71-7.606l1.09-1.677l11.71,7.606L110.56,209.608z M113.656,205.009l-16.18-11.755l1.176-1.618l16.18,11.756L113.656,205.009z
							 M116.997,200.571l-10.838-8.778l1.259-1.555l10.838,8.778L116.997,200.571z M120.562,196.317l-10.361-9.33l1.338-1.486l10.361,9.33
							L120.562,196.317z M124.343,192.256l-9.856-9.858l1.414-1.414l9.856,9.858L124.343,192.256z M128.332,188.398l-9.328-10.361
							l1.486-1.338l9.328,10.361L128.332,188.398z M132.518,184.754l-8.775-10.838l1.555-1.259l8.775,10.838L132.518,184.754z
							 M136.886,181.337l-11.755-16.181l1.618-1.176l11.755,16.181L136.886,181.337z M141.432,178.148l-7.603-11.709l1.678-1.089
							l7.603,11.709L141.432,178.148z M146.136,175.205l-6.984-12.101l1.732-1l6.984,12.101L146.136,175.205z M150.988,172.511
							l-6.346-12.458l1.782-0.908l6.346,12.458L150.988,172.511z M155.974,170.074l-5.689-12.782l1.827-0.813l5.689,12.782
							L155.974,170.074z M161.08,167.9l-4.97-13.088l1.87-0.71l4.97,13.088L161.08,167.9z M166.293,166.002l-6.18-19.021l1.902-0.618
							l6.18,19.021L166.293,166.002z M171.602,164.375l-3.625-13.531l1.932-0.518l3.625,13.531L171.602,164.375z M176.985,163.029
							l-2.912-13.703l1.956-0.416l2.912,13.703L176.985,163.029z M182.431,161.966l-2.19-13.833l1.976-0.313l2.19,13.833L182.431,161.966z
							 M187.926,161.19l-1.463-13.924l1.989-0.209l1.463,13.924L187.926,161.19z M193.455,160.702l-0.74-14.141l1.997-0.104l0.74,14.141
							L193.455,160.702z M201,160.505h-2l0.001-20h2L201,160.505z M206.548,160.702l-1.998-0.104l0.74-14.141l1.998,0.104L206.548,160.702
							z M212.075,161.19l-1.988-0.209l1.463-13.924l1.988,0.209L212.075,161.19z M217.57,161.966l-1.975-0.313l2.19-13.833l1.975,0.313
							L217.57,161.966z M223.018,163.029l-1.957-0.416l2.912-13.703l1.957,0.416L223.018,163.029z M226.469,163.858l3.625-13.531
							l1.932,0.518l-3.625,13.531L226.469,163.858z M231.807,165.384l6.18-19.021l1.902,0.618l-6.18,19.021L231.807,165.384z
							 M237.053,167.19l4.97-13.088l1.869,0.71l-4.97,13.088L237.053,167.19z M242.2,169.261l5.689-12.782l1.828,0.813l-5.689,12.782
							L242.2,169.261z M247.232,171.603l6.346-12.458l1.781,0.908l-6.346,12.458L247.232,171.603z M252.134,174.205l6.984-12.101l1.732,1
							l-6.984,12.101L252.134,174.205z M256.893,177.059l7.603-11.709l1.678,1.089l-7.603,11.709L256.893,177.059z M261.498,180.161
							l11.756-16.181l1.617,1.176l-11.756,16.181L261.498,180.161z M267.484,184.754l-1.555-1.259l8.775-10.838l1.555,1.259
							L267.484,184.754z M270.184,187.06l9.327-10.361l1.486,1.338l-9.327,10.361L270.184,187.06z M274.245,190.842l9.856-9.858
							l1.414,1.414l-9.856,9.858L274.245,190.842z M278.103,194.83l10.361-9.33l1.338,1.486l-10.361,9.33L278.103,194.83z
							 M281.747,199.016l10.839-8.778l1.258,1.555l-10.839,8.778L281.747,199.016z M285.17,203.392l16.18-11.756l1.176,1.618
							l-16.18,11.755L285.17,203.392z M288.353,207.93l11.71-7.606l1.09,1.677l-11.71,7.606L288.353,207.93z M291.297,212.634l12.1-6.992
							l1,1.732l-12.1,6.992L291.297,212.634z M293.99,217.487l12.461-6.351l0.908,1.781l-12.461,6.351L293.99,217.487z M297.241,224.298
							l-0.814-1.826l12.785-5.694l0.814,1.826L297.241,224.298z M298.6,227.578l13.073-5.021l0.717,1.867l-13.073,5.021L298.6,227.578z
							 M300.506,232.799l19.021-6.181l0.617,1.902l-19.021,6.181L300.506,232.799z M302.128,238.097l13.615-3.649l0.518,1.932
							l-13.615,3.649L302.128,238.097z M303.475,243.48l13.707-2.914l0.416,1.957l-13.707,2.914L303.475,243.48z M304.538,248.927
							l13.839-2.192l0.313,1.975l-13.839,2.192L304.538,248.927z M305.314,254.422l13.931-1.465l0.209,1.988l-13.931,1.465
							L305.314,254.422z M305.802,259.948l14.147-0.741l0.105,1.998l-14.147,0.741L305.802,259.948z M326.002,267.506h-20v-2h20V267.506z"
							/>
						<g class="grade-no">
							<text x="328" y="249">1</text>
							<text x="316" y="210">2</text>
							<text x="292" y="178">3</text>
							<text x="259" y="155">4</text>
							<text x="221" y="142">5</text>
							<text x="180" y="142">6</text>
							<text x="141" y="155">7</text>
							<text x="108" y="178">8</text>
							<text x="84" y="210">9</text>
							<text x="68" y="248">10</text>
						</g>
					</svg>
				</div>
				<div class="credit-banner">
					<dl>
						<a href="#" onclick="goSmartReportDetail();">
							<h4>나의 신용상태가 궁금하다면?</h4>
							<a href="#" onclick="goSmartReportDetail();" class="btn">나의 신용 통계분석</a>
						</a>
					</dl>
					<dl>
						<a href="#" onclick="goCreditRaise();">
							<h4>나의 신용점수를 올리려면?</h4>
							<a href="#" onclick="goCreditRaise();" class="btn">신용 점수 올리기</a>
						</a>
					</dl>
				</div>
			</div>
		</div>
		<div class="container-fluid credit-group">
			<a href="#" onclick="goFrameCreditInfoDetail('tab1');"> <h2 class="h2 block-container link-arrow">나의 신용정보 변동(최근1개월)</h2></a>
			<div class="credit-info-change">
				<dl onclick="goFrameCreditInfoDetail('tab1');">
					<dt>
						<c:choose>
							<c:when test="${!empty inquiryCnt}">
								<c:out value="${inquiryCnt}"/>
							</c:when>
							<c:otherwise>
								-
							</c:otherwise>
						</c:choose>
					</dt>
					<dd>신용조회정보</dd>
				</dl>
				<dl onclick="goFrameCreditInfoDetail('tab2');">
					<dt>
						<c:choose>
							<c:when test="${!empty loanCardCnt}">
								<c:out value="${loanCardCnt}"/>
							</c:when>
							<c:otherwise>
								-
							</c:otherwise>
						</c:choose>
					</dt>
					<dd>대출/카드정보</dd>
				</dl>
				<dl onclick="goFrameCreditInfoDetail('tab3');">
					<dt>
						<c:choose>
							<c:when test="${!empty overdueCnt}">
								<c:out value="${overdueCnt}"/>
							</c:when>
							<c:otherwise>
								-
							</c:otherwise>
						</c:choose>
					</dt>
					<dd>연체정보</dd>
				</dl>
			</div>
		</div>
		<div class="container-fluid credit-group">
			<h2 class="h2 block-container">나의 신용거래 현황</h2>
			<div class="list-group credit-list">
				<a href="<c:url value='/m/credit/frameCreditLoanInfo.crz'/>" class="list-group-item">
					<h3>대출현황
						<span class="badge">
							<c:choose>
								<c:when test="${!empty cntInfo.cnt_loan}">
									<c:out value="${cntInfo.cnt_loan}"/>건
								</c:when>
								<c:otherwise>
									-
								</c:otherwise>
							</c:choose>
						</span>
					</h3>
				</a>
				<a href="<c:url value='/m/credit/frameCreditCardInfo.crz'/>" class="list-group-item">
					<h3>카드현황
						<span class="badge">
							<c:choose>
								<c:when test="${!empty cntInfo.cnt_card}">
									<c:out value="${cntInfo.cnt_card}"/>건
								</c:when>
								<c:otherwise>
									-
								</c:otherwise>
							</c:choose>
						</span>
					</h3>
				</a>
				<a href="<c:url value='/m/credit/frameCreditOverdueInfo.crz'/>" class="list-group-item">
					<h3>연체현황
						<span class="badge">
							<c:choose>
								<c:when test="${!empty cntInfo.cnt_overdue}">
									<c:out value="${cntInfo.cnt_overdue}"/>건
								</c:when>
								<c:otherwise>
									-
								</c:otherwise>
							</c:choose>
						</span>
					</h3>
				</a>
				<a href="<c:url value='/m/credit/frameCreditGuaranteeInfo.crz'/>" class="list-group-item">
					<h3>연대보증현황
						<span class="badge">
							<c:choose>
								<c:when test="${!empty cntInfo.cnt_guarantee}">
									<c:out value="${cntInfo.cnt_guarantee}"/>건
								</c:when>
								<c:otherwise>
									-
								</c:otherwise>
							</c:choose>
						</span>
					</h3>
				</a>
			</div>
		</div>
		<!-- <div class="credit-banner">
			<a href="#" onclick="goSmartReportDetail();">
				<h4>나의 신용상태가 궁금하다면?</h4>
				<p>신용형태, 상환이력, 부채수준, 거래기간별</p>
				<a href="#" onclick="goSmartReportDetail();" class="btn">나의 신용 통계분석</a>
			</a>
		</div> -->
		<!--
		<div class="credit-list">
			<ul>
				<li>
					<a href="#" class="">
						<h3 class="status-card">카드거래</h3>
						<span class="badge">5</span>
					</a>
				</li>
				<li>
					<a href="#" class="">
					<h3 class="status-loan">대출거래</h3>
					<span class="badge">2</span>
				</a>
				</li>
				<li>
					<a href="#" class="">
					<h3 class="status-over">거래연체</h3>
					<span class="badge">0</span>
				</a>
				</li>
				<li>
					<a href="#" class="">
					<h3 class="status-surety">연대보증</h3>
					<span class="badge">2</span>
				</a>
				</li>
			</ul>
		</div> 
		 -->
	</section> 
	<!-- //Content -->
	<%@ include file="/WEB-INF/include/footer.jsp"%>
	<form name="frmStep" method="post"> 
	</form>
	<form name="frmDetail" method="post"> 
	<input type="hidden" id="detailTabNm" name="detailTabNm" value="tab1"/>
	</form>
</div>
</body>
</html>
