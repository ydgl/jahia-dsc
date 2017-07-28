<%@page language="java" contentType="text/html; charset=UTF-8" session="false"
%><!DOCTYPE html>
<%@ taglib uri="http://www.jahia.org/tags/internalLib" prefix="internal"%>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
response.setStatus(200);
response.setHeader("X-Robots-Tag", "noindex");
%>

<c:set var="originPath" value="${requestScope['javax.servlet.forward.request_uri']}"/>

<c:choose>
    <c:when test="${not empty originPath and fn:startsWith(originPath, '/Emploi/')}">
		<jsp:forward page="/fr/sites/cadres/home/404.html" />
	</c:when>
    <c:when test="${not empty originPath and fn:startsWith(originPath, '/Recrutement-Cadre/')}">
		<jsp:forward page="/fr/sites/www/home/404.html" />
	</c:when>
    <c:when test="${not empty originPath and fn:startsWith(originPath, '/Recrutement/')}">
		<jsp:forward page="/fr/sites/recruteurs/home/404.html" />
	</c:when>
	<c:when test="${not empty originPath and fn:startsWith(originPath, '/Emploi-stage/')}">
		<jsp:forward page="/fr/sites/jd/home/404.html" />
	</c:when>
	<c:when test="${not empty originPath and fn:startsWith(originPath, '/Presse/')}">
		<jsp:forward page="/fr/sites/presse/home/404.html"/>
	</c:when>
    <c:otherwise>
	<utility:setBundle basename="JahiaInternalResources"/>
	<html>
		<head>
			<meta charset="utf-8">
			<meta name="robots" content="noindex, nofollow"/>
			<link rel="stylesheet" href="${pageContext.request.contextPath}/css/errors.css" type="text/css"/>
			<title><fmt:message key="label.error.404.title"/></title>
		<head>
		<body class="error-page" onLoad="if (history.length > 1) { document.getElementById('backLink').style.display=''; }">
			<div class="row-fluid login-wrapper">
				<div class="span4 box error-box">
					<div class="content-wrap">
						<h1 class="message-big"><fmt:message key="label.error.404.title"/></h1>
						<p><fmt:message key="label.error.404.description"/></p>
						<p id="backLink" style="display:none">
							<a class="btn btn-large btn-block" href="javascript:history.back()">
								<i class="icon-chevron-left"></i>
								&nbsp;<fmt:message key="label.error.backLink.1"/>
								&nbsp;<fmt:message key="label.error.backLink.2"/>
								&nbsp;<fmt:message key="label.error.backLink.3"/>
							</a>
						</p>
						<p><fmt:message key="label.error.homeLink"/></p>
						<a class="btn btn-large btn-block btn-primary" href="<c:url value='/'/>">
							<i class="icon-home icon-white"></i>
							&nbsp;<fmt:message key="label.homepage"/>
						</a>
					</div>
				</div>
			</div>
		</body>
    </c:otherwise>  
 </c:choose>  


