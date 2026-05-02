<%@page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %> <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %> <%@ taglib prefix="fn" uri="jakarta.tags.functions" %> <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta content="width=device-width,initial-scale=1" name="viewport" />
        <title>TaskFlow — Project Management</title>
        <script> (function () {
                try {
                    if (localStorage.getItem("pm.sidebar.collapsed") === "1") {
                    	document.documentElement.classList.add("pref-sidebar-collapsed");
                    }
                }
                catch (e) {}
            })();
        </script>
        <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet" />
        <link href="${pageContext.request.contextPath}/css/bootstrap-icons.min.css" rel="stylesheet" />
        <link href="${pageContext.request.contextPath}/css/theme.css" rel="stylesheet" />
        <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet" />
    </head>
    <body class="app-body">
        <header class="app-topbar">
            <div class="container-fluid px-3">
                <button class="btn-icon me-2" type="button" aria-label="Toggle navigation" data-sidebar-toggle="true" id="sidebarToggle">
                    <i class="bi bi-list fs-5"></i>
                </button>
                <a href="${pageContext.request.contextPath}/dashboard" class="app-brand me-4">
                    <i class="bi bi-grid-1x2-fill"></i>
                    TaskFlow
                </a>
                <div class="flex-grow-1"></div>
                <div class="align-items-center d-flex gap-2 ms-3">
                    <div class="dropdown">
                        <button class="account-menu-trigger btn btn-light btn-sm dropdown-toggle shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Open account menu">
                            <i class="bi bi-person-circle"></i>
                            <span class="account-menu-username"><sec:authentication property="name" /></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end account-menu-dropdown">
                            <li>
                                <a href="${pageContext.request.contextPath}/profile" class="dropdown-item account-dropdown-item">
                                    <i class="bi bi-person-circle"></i>
                                    <span>Profile</span>
                                </a>
                            </li>
                            <li><hr class="dropdown-divider" /></li>
                            <li>
                                <form action="${pageContext.request.contextPath}/logout" class="mb-0" method="post">
                                    <input name="${_csrf.parameterName}" type="hidden" value="${_csrf.token}" />
                                    <button class="dropdown-item account-dropdown-item account-dropdown-item--danger" type="submit">
                                        <i class="bi bi-box-arrow-right"></i>
                                        <span>Logout</span>
                                    </button>
                                </form>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </header>
        <c:set value="${pageContext.request.contextPath}" var="headerContextPath" />
        <c:set value="${pageContext.request.requestURI}" var="headerCurrentUri" />
        <c:set value="${fn:replace(headerCurrentUri, headerContextPath, '')}" var="headerRelativeUri" />
        <c:set value="${fn:split(headerRelativeUri, '/')}" var="headerUriParts" />
        <c:set value="" var="headerProjectId" />
        <c:choose>
            <c:when test="${not empty project and not empty project.id}">
                <c:set value="${project.id}" var="headerProjectId" />
            </c:when>
            <c:when test="${not empty projectId}">
                <c:set value="${projectId}" var="headerProjectId" />
            </c:when>
            <c:when test="${not empty workPackage and not empty workPackage.projectId}">
                <c:set value="${workPackage.projectId}" var="headerProjectId" />
            </c:when>
            <c:when test="${not empty param.projectId}">
                <c:set value="${param.projectId}" var="headerProjectId" />
            </c:when>
            <c:when test="${fn:length(headerUriParts) gt 2 and headerUriParts[1] == 'projects' and headerUriParts[2] != 'new'}">
                <c:set value="${headerUriParts[2]}" var="headerProjectId" />
            </c:when>
            <c:when test="${fn:length(headerUriParts) gt 3 and headerUriParts[1] == 'work-packages' and headerUriParts[2] == 'project'}">
                <c:set value="${headerUriParts[3]}" var="headerProjectId" />
            </c:when>
        </c:choose>
        <c:set value="" var="headerProjectLabel" />
        <c:choose>
            <c:when test="${not empty project and not empty project.name}">
                <c:set value="${project.name}" var="headerProjectLabel" />
            </c:when>
            <c:when test="${not empty projectName}">
                <c:set value="${projectName}" var="headerProjectLabel" />
            </c:when>
            <c:when test="${not empty workPackage and not empty workPackage.projectName}">
                <c:set value="${workPackage.projectName}" var="headerProjectLabel" />
            </c:when>
            <c:when test="${not empty headerProjectId}">
                <c:set value="Project #${headerProjectId}" var="headerProjectLabel" />
            </c:when>
        </c:choose>
        <c:set value="" var="headerSectionLabel" />
        <c:set value="" var="headerSectionHref" />
        <c:set value="" var="headerLeafLabel" />
        <c:choose>
            <c:when test="${fn:contains(headerRelativeUri, '/work-packages/project/')}">
                <c:set value="Work packages" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/work-packages/project/${headerProjectId}" var="headerSectionHref" />
                <c:choose>
                    <c:when test="${not empty param.typeId or not empty param.statusId or not empty param.priorityId or not empty param.assigneeId}">
                        <c:set value="Filtered list" var="headerLeafLabel" />
                    </c:when>
                    <c:otherwise>
                        <c:set value="Default: All open" var="headerLeafLabel" />
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/kanban')}">
                <c:set value="Work packages" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/work-packages/project/${headerProjectId}" var="headerSectionHref" />
                <c:set value="Kanban board" var="headerLeafLabel" />
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/gantt')}">
                <c:set value="Work packages" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/work-packages/project/${headerProjectId}" var="headerSectionHref" />
                <c:set value="Gantt chart" var="headerLeafLabel" />
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/projects/') and fn:contains(headerRelativeUri, '/edit') and not fn:contains(headerRelativeUri, '/members/')}">
                <c:set value="Edit" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/projects/${headerProjectId}/edit" var="headerSectionHref" />
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/members')}">
                <c:set value="Members" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/projects/${headerProjectId}/members" var="headerSectionHref" />
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/lifecycles')}">
                <c:set value="Lifecycle" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/projects/${headerProjectId}" var="headerSectionHref" />
                <c:choose>
                    <c:when test="${fn:contains(headerRelativeUri, '/lifecycles/new')}">
                        <c:set value="New phase" var="headerLeafLabel" />
                    </c:when>
                    <c:when test="${fn:contains(headerRelativeUri, '/lifecycles/') and fn:contains(headerRelativeUri, '/edit')}">
                        <c:set value="Edit phase" var="headerLeafLabel" />
                    </c:when>
                </c:choose>
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/settings')}">
                <c:set value="Settings" var="headerSectionLabel" />
                <c:set value="${headerContextPath}/projects/${headerProjectId}/settings" var="headerSectionHref" />
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/work-packages')}">
                <c:set value="Work packages" var="headerSectionLabel" />
                <c:choose>
                    <c:when test="${not empty headerProjectId}">
                        <c:set value="${headerContextPath}/work-packages/project/${headerProjectId}" var="headerSectionHref" />
                        <c:if test="${not fn:contains(headerRelativeUri, '/project/')}">
                            <c:set value="${empty workPackage.subject ? 'Work Package View' : workPackage.subject}" var="headerLeafLabel" />
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <c:set value="${headerContextPath}/work-packages" var="headerSectionHref" />
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:when test="${fn:contains(headerRelativeUri, '/projects')}">
                <c:choose>
                    <c:when test="${empty headerProjectLabel}">
                        <c:set value="Projects" var="headerSectionLabel" />
                        <c:set value="${headerContextPath}/projects" var="headerSectionHref" />
                    </c:when>
                    <c:when test="${not fn:contains(headerRelativeUri, '/edit') and not fn:contains(headerRelativeUri, '/members') and not fn:contains(headerRelativeUri, '/lifecycles') and not fn:contains(headerRelativeUri, '/settings')}">
                        <c:set value="Overview" var="headerLeafLabel" />
                    </c:when>
                </c:choose>
            </c:when>
        </c:choose>
        <sec:authorize access="isAuthenticated()">
            <nav aria-label="Breadcrumb" class="top-breadcrumb-nav">
                <div class="container-fluid px-3">
                    <ol class="mb-0 app-breadcrumb breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${headerContextPath}/dashboard" class="text-decoration-none" title="Home">
                                <i class="bi bi-house-door"></i>
                            </a>
                        </li>
                        <c:if test="${empty headerProjectLabel and empty headerSectionLabel}">
                            <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                        </c:if>
                        <c:if test="${not empty headerProjectLabel}">
                            <li class="breadcrumb-item">
                                <a href="${headerContextPath}/projects/${headerProjectId}">${headerProjectLabel}</a>
                            </li>
                        </c:if>
                        <c:if test="${not empty headerSectionLabel}">
                            <li class="breadcrumb-item ${empty headerLeafLabel ? 'active' : ''}" ${empty headerLeafLabel ? 'aria-current="page"' : ''}>
                                <c:choose>
                                    <c:when test="${empty headerLeafLabel}">
                                        ${headerSectionLabel}
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${headerSectionHref}">${headerSectionLabel}</a>
                                    </c:otherwise>
                                </c:choose>
                            </li>
                        </c:if>
                        <c:if test="${not empty headerLeafLabel}">
                            <li class="breadcrumb-item active" aria-current="page">
                                <span class="d-inline-block text-truncate" style="max-width: 200px; vertical-align: bottom;" title="${headerLeafLabel}">
                                    ${headerLeafLabel}
                                </span>
                            </li>
                        </c:if>
                    </ol>
                </div>
            </nav>
        </sec:authorize>
        <div class="app-shell">
            <sec:authorize access="isAuthenticated()">
                <aside class="app-sidebar" id="mainSidebar"><%@ include file="sidebar.jsp" %></aside>
            </sec:authorize>
            <div class="app-content">
                <main class="container-fluid content-container">
