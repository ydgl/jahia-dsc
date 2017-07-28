<%@page language="java" contentType="text/html; charset=UTF-8"
	session="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Accueil</title>
<link rel="icon"
	href="/modules/apec-template-bootstrap-responsive/icons/favicon.ico"
	type="image/ico">

<meta name="author" content="Apec site RH" />
<meta name="copyright" content="Association Pour l’Emploi des Cadres" />
<meta name="MSSmartTagsPreventParsing" content="TRUE" />
<link href="<c:url value='/modules/bootstrap3-core/css/bootstrap.css'/>"
	rel="stylesheet"/>
<link rel="stylesheet"
	href="<c:url value='/modules/apec-template-bootstrap-responsive/css/nousrejoindre/nousrejoindre.css' />" media="all" type="text/css"/>
<link rel="stylesheet"
	href="<c:url value='/modules/apec-template-bootstrap-responsive/css/nousrejoindre/websitetoolbar.css' />"
	media="all" type="text/css" />
<script type="text/javascript"
	src="<c:url value='/modules/jquery/javascript/jquery.min.js' />"></script>
<script type="text/javascript"
	src="<c:url value='/modules/assets/javascript/jquery.jahia.min.js' />"></script>
<script type="text/javascript"
	src="<c:url value='/modules/apec-template-bootstrap-responsive/javascript/external/jquery-ui.min.js' />"></script>
	
</head>
<body> 
	<div class="container" id="siteNousRejoindre">
		<div class="main">
			<div class="container">
				<section class="" id="header">
					<div class="row">
						<div class="col-md-12">
							<div id="entete">
								<!-- Top menu area: START -->
								<div id="logo" onclick="location.href='/accueil.html';"
									style="cursor: pointer; width: 250px; height: 112px;"></div>

								<div id="menu">

									<ul>
										<li><a class="lvl1">Nous connaître</a>
											<ul style="display: none;">
												<li><a class="menuClass"
													href="/accueil/nous-connaitre/qui-sommes-nous">Qui
														sommes nous ?</a></li>
												<li><a class="menuClass"
													href="/accueil/nous-connaitre/lapec-en-chiffres">
														L’Apec en chiffres </a></li>

											</ul></li>
									</ul>

									<ul>
										<li><a class="lvl1"> Nos axes RH </a>
											<ul style="display: none;">

												<li><a class="menuClass"
													href="/accueil/nos-axes-rh/alternance"> Alternance </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-axes-rh/evolution"> Evolution </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-axes-rh/mobilite-interne"> Mobilité
														interne </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-axes-rh/formation"> Formation </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-axes-rh/management"> Management </a></li>

											</ul></li>
									</ul>

									<ul>
										<li><a class="lvl1"> Nos métiers </a>
											<ul style="display: none;">

												<li><a class="menuClass"
													href="/accueil/nos-metiers/conseil-rh"> Conseil RH </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-metiers/etudes-et-prospective">
														Etudes et prospective </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-metiers/developpement-et-relations-clients">
														Développement et relations clients </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-metiers/systeme-dinformation-moa-et-decisionnel">
														Système d'Information, MOA et décisionnel </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-metiers/rh-et-communication"> RH et
														communication </a></li>

												<li><a class="menuClass"
													href="/accueil/nos-metiers/marketing-et-digital">
														Marketing et Digital </a></li>

											</ul></li>
									</ul>

									<ul>
										<li><a class="lvl1"> Postulez </a>
											<ul style="display: none;">

												<li><a class="menuClass"
													href="/accueil/postulez/pour-travailler-a-lapec-nos-offres">
														Pour travailler à l'Apec, nos offres </a></li>

												<li><a class="menuClass"
													href="/accueil/postulez/notre-processus-de-recrutement">
														Notre processus de recrutement </a></li>

												<li><a class="menuClass"
													href="/accueil/postulez/votre-integration"> Votre
														intégration </a></li>

											</ul></li>
									</ul>

								</div>

								<script type="text/javascript">
		jQuery(document).ready(function($) {
			$("#menu ul li ul").hide();
			$("#menu ul li a.lvl1").mouseover(function() {
				$("#menu ul li ul").hide();
				$(this).next("ul").show();
			});
			$("#menu").mouseout(function() {
				$("#menul ul li ul").hide();
			});
			$("#menu ul li ul").mouseover(function() {
				$(this).show();
			});
		});
	</script>


							</div>
							<div class="clear"></div>
							<ul class="breadcrumb"><li><a href="/accueil.html">&nbsp;&nbsp;Accueil</a></li><li>Page introuvable</li></ul>
						</div>
					</div>
				</section>

				<section class="" id="main">
					<div class="row">
						<div class="col-md-12" style="min-height:400px">
						<div style="padding:100px 60px;">
						<h3 class="">Le contenu que vous cherchez à afficher n'est plus accessible.</h3>
						<hr>
						<div class="clearfix">
						<p class="pull-left"><a href="/accueil.html" class="error-link">Page d'accueil</a></p>
            </div><!--/clearfix-->
        </div>
						</div>
					</div>	
				</section>


				<section class="" id="footer">
					<div class="row ">
						<div class="col-md-12">
							<div id="footer">
								<ul>
									<li><a href="http://www.apec.fr" target="_blank">apec.fr</a></li>
									<li>|</li>
									<li><a
										href="https://www.apec.fr/home/apec-landing-page.html"
										target="_blank">Applis mobiles</a></li>

									<li>|</li>
									<li><a href="/accueil/contact">Contact</a></li>

									<li>|</li>
									<li class="twitter"><a
										href="http://twitter.com/Apec_Recrute" target="_blank"><img
											src="/modules/apec-template-bootstrap-responsive/images/nousrejoindre/bt_twitter.gif" /></a></li>

									<li>|</li>
									<li><a href="/accueil/mentions-legales">Mentions
											légales</a></li>

								</ul>
							</div>
							<div class="clear"></div>
						</div>
					</div>
				</section>
				<div class="clear"></div>
			</div>
		</div>
	</div>
</body>
</html>