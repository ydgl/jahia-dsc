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

	<title>500 - Erreur technique</title>

    <!-- Bootstrap core CSS -->
    <link href="<c:url value='/modules/bootstrap3-core/css/bootstrap.css'/>" rel="stylesheet">
    <!-- Theme APEC -->
    <link href="<c:url value='/modules/apec-template-bootstrap-responsive/css/apec.css'/>" rel="stylesheet">
      

</head>
<body id="recruteurs" class="error-page"
	onLoad="if (history.length > 1) { document.getElementById('backLink').style.display=''; }">


    <div class="container">

        <div class="" id="topsite">
            <div class="clearfix">
                <ul id="sites-apec">
                    <li><a href="https://www.apec.fr">Accueil Apec</a><span>|</span></li>
                    <li><a href="https://cadres.apec.fr">Cadres</a><span>|</span></li>
                    <li><a href="https://jd.apec.fr">Jeunes Diplômés</a><span>|</span></li>
                    <li class="topBarActive">Recruteurs</li>
                </ul>
            </div>
        </div><!--/topsite-->
        
        <div id="logintop">
            <p id="identification"></p>
        </div><!--/logintop-->
        
        <div id="topBar">
            <a href="/" class="logo" title="Association Pour l'Emploi des Cadres - Prenez rendez-vous avec l'avenir."></a>
            <div id="togglemenu"></div>
                <div class="clearfix">
                    <nav class="navbar navbar-default" role="navigation">
                        <div class="container-fluid">
                            <div class="navbar-header">
                                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                                    <span class="sr-only">Toggle navigation</span>  <span class="icon-bar"></span>  <span class="icon-bar"></span>  <span class="icon-bar"></span>
                                </button>
                            </div>
                            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                                <ul class="nav navbar-nav">
                                    <li id="onglet1" ><a href="/home.html">Accueil</a></li>              
                                    <li id="onglet2" ><a href="/Recrutement/Vos-services-RH-Apec">Les Services Apec</a></li>
                                    <li id="onglet3" ><a href="/home/gerer-vos-offres.html">Gérer<br class="hidden-xs hidden-sm"/> vos offres</a></li>
                                    <li id="onglet4" ><a href="/home/consulter-les-cv.html">Consulter<br class="hidden-xs hidden-sm"/> les CV</a></li>   
                                    <li id="onglet5" ><a href="/Recrutement/Pratique-RH">Pratique RH</a></li>              
                                    <li id="onglet6" ><a href="/Recrutement/Observatoire-de-l-emploi">Observatoire<br class="hidden-xs hidden-sm"/> de l'emploi</a></li>
                                    <li id="onglet7" ><a href="/home/reseau-pro.html">Réseau Pro</a></li>
                                    <li id="onglet8" ><a href="/home/votre-compte-apec.html">Votre compte<br class="hidden-xs hidden-sm"/> Apec</a></li>
                                </ul>
                            </div><!-- /.navbar-collapse -->
                        </div><!-- /.container-fluid -->
                    </nav>
                </div><!--/clearfix-->
        </div><!--/topBar-->

		
        <div class="content" id="chenillard">
            <ul class="breadcrumb">
                <li><a href="<c:url value='/'/>">Accueil</a></li>
                <li>Une erreur est survenue</li>
            </ul>
        </div>
        
        <div class="content sans-resultat">
            <h3 class="">Un problème technique nous empêche de vous rendre le service attendu. Veuillez revenir plus tard ou bien de continuer à naviguer en mode déconnecté.</h3>
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
                    <li><a href="/Emploi/Accueil-APEC/Qui-sommes-nous">Qui sommes-nous ?</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://nousrejoindre.apec.fr" target="_blank">Nous rejoindre</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://presse.apec.fr" target="_blank">Espace Presse</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="http://www.apec.marches-publics.info" target="_blank">Appels d'offre</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="https://www.apec.fr/home/apec-landing-page.html" class="iphone">Mobile</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Mon-compte/Vous-avez-une-question-sur-le-site/Categories">FAQ</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Accueil-APEC/Partenaires">Partenaires</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/Emploi/Accueil-APEC/Infos-legales">Infos légales</a></li>
                    <li class="coloredWhite">|</li>
                    <li><a href="/" id="copyright">&copy; Apec</a></li>
                </ul>
            </div>
        </div><!--/bottombar-->

        <div class="content" id="footer">
            <div class="visible-xs">
                <div class="clearfix">
                <ul id="sites-apec">
                    <li><a href="https://www.apec.fr">Accueil Apec</a><span>|</span></li>
                    <li><a href="https://cadres.apec.fr">Cadres</a><span>|</span></li>
                    <li><a href="https://jd.apec.fr">Jeunes Diplômés</a><span>|</span></li>
                    <li class="topBarActive">Recruteurs</li>
                </ul>
                </div><!--/clearfix-->
            </div><!--/visible-xs-->
        </div><!--/footer-->
        
    </div><!--/container-->
</body>
</html>