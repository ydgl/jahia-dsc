<%@page language="java" contentType="text/html; charset=UTF-8"
	session="false"%><!DOCTYPE html>
<%@ taglib uri="http://www.jahia.org/tags/internalLib" prefix="internal"%>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib"%>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<utility:setBundle basename="JahiaInternalResources" />
<html>
<head>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
	<meta name="robots" content="noindex, nofollow" />
    <link rel="icon" href="">

	<title><fmt:message key="label.error.404.title" /></title>

    <!-- Bootstrap core CSS -->
    <link href="<c:url value='/modules/bootstrap3-core/css/bootstrap.css'/>" rel="stylesheet">
    <!-- Theme APEC -->
    <link href="<c:url value='/modules/apec-template-bootstrap-responsive/css/apec.css'/>" rel="stylesheet">
      

</head>
<body id="www" class="error-page"
	onLoad="if (history.length > 1) { document.getElementById('backLink').style.display=''; }">


	    <div class="container">

        <div class="" id="topsite">
            <div class="clearfix">
                 <ul id="sites-apec">
                     <li></li>
                     <li></li>
                     <li></li>
                     <li></li>
                  </ul>   
            </div>
        </div><!--/topsite-->
        
        <div id="logintop">
            <p id="identification"></p>
        </div><!--/logintop-->
        
        <div id="topBar">
            <a href="/" class="logo" title="Association Pour l'Emploi des Cadres - Prenez rendez-vous avec l'avenir."></a> 
            <div class="clearfix">
                <p class="pull-left border-right"><strong>L'APEC, C'EST</strong></p>
                <p class="pull-left border-right"><strong>500 consultants à votre &eacute;coute</strong></p>  
                <p class="pull-left border-right"><strong>39 000 entreprises</strong></p>  
                <p class="pull-left border-right"><strong>800 000 candidats</strong></p>  
            </div><!--/clearfix-->
        </div><!--/topbar-->
        
        <div class="content sans-resultat">
            <h3 class="">Le contenu que vous cherchez à afficher n'est plus accessible.</h3>
            <hr>
            <div class="clearfix">
                <p class="pull-left"><a href="<c:url value='/'/>" class="button-big button-grey">Page d'accueil</a></p>
				<p id="backLink" class="pull-left" style="display: none">
					<a class="button-big button-green" href="javascript:history.back()">
						Retour
					</a>
				</p>
            </div><!--/clearfix-->
        </div>
        
        <div class="" id="bottombar">
            <div>
                <ul class="clearfix">
                    <li><a href="https://www.apec.fr/Recrutement-Cadre/Qui-sommes-nous/Qui-sommes-nous">Qui sommes-nous ?</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://nousrejoindre.apec.fr" target="_blank">Nous rejoindre</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://presse.apec.fr" target="_blank">Espace Presse</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://www.apec.marches-publics.info" target="_blank">Appels d'offre</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="https://wwwint1.apec.fr/home/apec-landing-page.html" class="iphone">Mobile</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Mon-compte/Vous-avez-une-question-sur-le-site/Categories">FAQ</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Accueil-APEC/Partenaires">Partenaires</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Accueil-APEC/Infos-legales">Infos légales</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="https://cadresint1.apec.fr" id="copyright">&copy; Apec</a></li>
                </ul>
            </div>
        </div><!--/bottombar-->
        
    </div><!--/container-->

</body>
</html>