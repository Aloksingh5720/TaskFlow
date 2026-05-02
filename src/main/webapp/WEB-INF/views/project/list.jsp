<%@include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    /* Allow dropdowns to overflow table container */
    .table-responsive {
        overflow: visible;
    }
    .card-body {
        overflow: visible;
    }
    /* Ensure dropdown menu appears above other content */
    .dropdown-menu {
        z-index: 1050;
    }

    .project-name-header {
        padding-left: 7rem !important;
    }
</style>

<div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
    <div>
        <h2 class="mb-1 fw-semibold">Projects</h2>
        <p class="mb-0 text-muted small">Manage project structure, ownership, and visibility.</p>
    </div>
    <sec:authorize access="hasAnyAuthority('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
        <button type="button" class="btn btn-primary d-inline-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#createProjectModal">
            <i class="bi bi-plus-lg"></i>
            New Project
        </button>
    </sec:authorize>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="p-4 pb-0">
            <div class="search-container search-compact">
                <form method="get" action="${pageContext.request.contextPath}/projects" class="search-container__form">
                    <input type="hidden" name="page" value="0" />
                    <input type="hidden" name="size" value="${projects.size}" />
                    <input type="hidden" name="sort" value="${empty param.sort ? 'id,desc' : param.sort}" />
                    <div class="search-container__row" style="align-items: center;">
                        <div class="search-container__group" style="max-width: 520px;">
                            <div class="search-input-wrapper">
                                <i class="bi bi-search search-input-icon"></i>
                                <input type="text" name="search" value="${search}" class="search-input"
                                    placeholder="Search by project ID or project name" />
                                <c:if test="${not empty search}">
                                    <button type="button" class="search-input-clear" onclick="document.getElementById('search').value='';this.closest('form').submit();">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </c:if>
                            </div>
                        </div>
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <button type="submit" class="btn btn-outline-primary search-btn" style="height: 40px;">
                                <i class="bi bi-search"></i> Search
                            </button>
                            <c:if test="${not empty search}">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/projects" style="height: 40px;">
                                    <i class="bi bi-x-circle"></i> Clear
                                </a>
                            </c:if>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <div class="px-4">
        <c:choose>
            <c:when test="${empty projects.content}">
                <div class="d-flex flex-column align-items-center justify-content-center text-center text-muted py-5 px-4 my-3">
                    <div class="mb-3 opacity-25">
                        <i class="bi bi-folder-x" style="font-size: 3.5rem;"></i>
                    </div>
                    <p class="fs-5 fw-medium mb-1 text-body">${not empty search ? 'No matching projects found' : 'No projects yet'}</p>
                    <p class="text-muted small mb-3">${not empty search ? 'Try a different project ID or project name.' : 'Get started by creating your first project.'}</p>
                    <sec:authorize access="hasAnyAuthority('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
                        <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#createProjectModal">
                            <i class="bi bi-plus-lg me-1"></i> Create Project
                        </button>
                    </sec:authorize>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4 py-3 fw-medium text-muted small text-uppercase border-bottom" style="width: 140px">Project ID</th>
                                <th class="project-name-header py-3 fw-medium text-muted small text-uppercase ls-wide border-bottom">Project</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom" style="width: 120px">Status</th>
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Created On</th>
                                <th class="pe-4 py-3 fw-medium text-muted small text-uppercase border-bottom text-end" style="width: 80px">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="project" items="${projects.content}">
                                <c:set value="${childProjectsByParentId[project.id]}" var="childProjects" />
                                <c:set value="${empty childProjects ? 0 : fn:length(childProjects)}" var="childCount" />

                                    <%-- ── Parent row ── --%>
                                    <tr class="project-row-parent">
                                        <td class="ps-4 py-3 text-muted small fw-semibold">${not empty project.uiId ? project.uiId : project.id}</td>
                                        <td class="ps-4 py-3">
                                            <div class="d-flex align-items-center gap-3">
                                                <c:choose>
                                                    <c:when test="${childCount > 0}">
                                                        <button
                                                            type="button"
                                                            aria-expanded="false"
                                                            aria-label="Toggle child projects"
                                                            class="btn btn-sm btn-link p-0 text-secondary text-decoration-none js-child-toggle"
                                                            data-parent-id="${project.id}">
                                                            <i class="bi bi-chevron-right js-child-toggle-icon"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <%-- spacer to keep name aligned --%>
                                                        <span class="d-inline-block" style="width: 1.25rem;"></span>
                                                    </c:otherwise>
                                                </c:choose>

                                                <span class="d-inline-flex align-items-center justify-content-center rounded-3 bg-primary bg-opacity-10 text-primary flex-shrink-0" style="width:36px;height:36px;">
                                                    <i class="bi bi-folder2-open"></i>
                                                </span>

                                                <div class="d-flex flex-column">
                                                    <a href="${pageContext.request.contextPath}/projects/${project.id}" class="fw-semibold text-body text-decoration-none link-hover-primary">${project.name}</a>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="py-3">
                                            <c:choose>
                                                <c:when test="${project.projectStatus == 'ON_TRACK' || project.projectStatus == 'FINISHED'}">
                                                    <span class="badge rounded-pill text-bg-success">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:when test="${project.projectStatus == 'AT_RISK'}">
                                                    <span class="badge rounded-pill text-bg-warning">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:when test="${project.projectStatus == 'OFF_TRACK' || project.projectStatus == 'DISCONTINUED'}">
                                                    <span class="badge rounded-pill text-bg-danger">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge rounded-pill text-bg-secondary">${fn:replace(project.projectStatus, '_', ' ')}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="py-3 text-muted small">
                                            <c:choose>
                                                <c:when test="${project.createdAt != null}">
                                                    <i class="bi bi-calendar3 me-1 opacity-50"></i>
                                                    ${fn:replace(fn:substring(project.createdAt, 0, 16), 'T', ' ')}
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="py-3 pe-4 text-end">
                                            <div class="dropdown">
                                                <button
                                                    type="button"
                                                    aria-expanded="false"
                                                    aria-label="Project actions"
                                                    class="btn btn-sm btn-outline-secondary border-0"
                                                    data-bs-toggle="dropdown"
                                                    data-bs-boundary="viewport"
                                                    data-bs-strategy="fixed">
                                                    <i class="bi bi-three-dots-vertical"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                    <li>
                                                        <a href="${pageContext.request.contextPath}/projects/${project.id}" class="dropdown-item d-flex align-items-center gap-2">
                                                            <i class="bi bi-eye text-muted"></i> View
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <button type="button" class="dropdown-item d-flex align-items-center gap-2"
                                                            data-bs-toggle="modal" data-bs-target="#editProjectModal"
                                                            data-edit-action="${pageContext.request.contextPath}/projects/${project.id}"
                                                            data-project-name="${project.name}"
                                                            data-project-description="${project.description}"
                                                            data-project-parent-id="${project.parentId}"
                                                            data-project-status="${project.projectStatus}">
                                                            <i class="bi bi-pencil text-muted"></i> Edit
                                                        </button>
                                                    </li>
                                                    <c:if test="${canDeleteProjectById[project.id]}">
                                                        <li><hr class="dropdown-divider"></li>
                                                        <li>
                                                            <button type="button" class="dropdown-item d-flex align-items-center gap-2 text-danger"
                                                                data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                                                data-delete-action="${pageContext.request.contextPath}/projects/${project.id}/delete"
                                                                data-delete-message="Are you sure you want to delete project '${project.name}'? This action cannot be undone.">
                                                                <i class="bi bi-trash"></i> Delete
                                                            </button>
                                                        </li>
                                                    </c:if>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>

                                    <%-- ── Child rows ── --%>
                                    <c:forEach var="childProject" items="${childProjects}">
                                            <tr class="d-none table-light project-child-of-${project.id} project-child-row">
                                                <td class="ps-4 py-3 text-muted small fw-semibold">${not empty childProject.uiId ? childProject.uiId : childProject.id}</td>
                                                <td class="py-3 ps-4">
                                                    <div class="d-flex align-items-start gap-3">
                                                        <%-- tree branch spacer --%>
                                                        <span class="d-inline-block flex-shrink-0 text-center" style="width:1.25rem;"></span>
                                                        <span class="d-inline-block flex-shrink-0 text-muted opacity-50" style="width:1rem;">
                                                            <i class="bi bi-arrow-return-right"></i>
                                                        </span>

                                                        <span class="d-inline-flex align-items-center justify-content-center rounded-3 bg-secondary bg-opacity-10 text-secondary flex-shrink-0" style="width:32px;height:32px;">
                                                            <i class="bi bi-diagram-3 small"></i>
                                                        </span>

                                                        <div class="d-flex flex-column">
                                                            <a href="${pageContext.request.contextPath}/projects/${childProject.id}" class="fw-semibold text-body text-decoration-none">${childProject.name}</a>
                                                            <span class="text-muted small">
                                                                <c:choose>
                                                                    <c:when test="${not empty childProject.description}">${childProject.description}</c:when>
                                                                    <c:otherwise>No description available.</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="py-3">
                                                    <c:choose>
                                                        <c:when test="${childProject.projectStatus == 'ON_TRACK' || childProject.projectStatus == 'FINISHED'}">
                                                            <span class="badge rounded-pill text-bg-success">${fn:replace(childProject.projectStatus, '_', ' ')}</span>
                                                        </c:when>
                                                        <c:when test="${childProject.projectStatus == 'AT_RISK'}">
                                                            <span class="badge rounded-pill text-bg-warning">${fn:replace(childProject.projectStatus, '_', ' ')}</span>
                                                        </c:when>
                                                        <c:when test="${childProject.projectStatus == 'OFF_TRACK' || childProject.projectStatus == 'DISCONTINUED'}">
                                                            <span class="badge rounded-pill text-bg-danger">${fn:replace(childProject.projectStatus, '_', ' ')}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge rounded-pill text-bg-secondary">${fn:replace(childProject.projectStatus, '_', ' ')}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="py-3 text-muted small">
                                                    <c:choose>
                                                        <c:when test="${childProject.createdAt != null}">
                                                            <i class="bi bi-calendar3 me-1 opacity-50"></i>
                                                            ${fn:replace(fn:substring(childProject.createdAt, 0, 16), 'T', ' ')}
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="py-3 pe-4 text-end">
                                                    <div class="dropdown">
                                                        <button
                                                            type="button"
                                                            aria-expanded="false"
                                                            aria-label="Project actions"
                                                            class="btn btn-sm btn-outline-secondary border-0"
                                                            data-bs-toggle="dropdown"
                                                            data-bs-boundary="viewport"
                                                            data-bs-strategy="fixed">
                                                            <i class="bi bi-three-dots-vertical"></i>
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                            <li>
                                                                <a href="${pageContext.request.contextPath}/projects/${childProject.id}" class="dropdown-item d-flex align-items-center gap-2">
                                                                    <i class="bi bi-eye text-muted"></i> View
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <button type="button" class="dropdown-item d-flex align-items-center gap-2"
                                                                    data-bs-toggle="modal" data-bs-target="#editProjectModal"
                                                                    data-edit-action="${pageContext.request.contextPath}/projects/${childProject.id}"
                                                                    data-project-name="${childProject.name}"
                                                                    data-project-description="${childProject.description}"
                                                                    data-project-parent-id="${childProject.parentId}"
                                                                    data-project-status="${childProject.projectStatus}">
                                                                    <i class="bi bi-pencil text-muted"></i> Edit
                                                                </button>
                                                            </li>
                                                            <c:if test="${canDeleteProjectById[childProject.id]}">
                                                                <li><hr class="dropdown-divider"></li>
                                                                <li>
                                                                    <button type="button" class="dropdown-item d-flex align-items-center gap-2 text-danger"
                                                                        data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                                                        data-delete-action="${pageContext.request.contextPath}/projects/${childProject.id}/delete"
                                                                        data-delete-message="Are you sure you want to delete project '${childProject.name}'? This action cannot be undone.">
                                                                        <i class="bi bi-trash"></i> Delete
                                                                    </button>
                                                                </li>
                                                            </c:if>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                    </c:forEach>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
        </div>
    </div>
</div>

<%-- Pagination --%>
<c:if test="${projects.totalPages > 1}">
    <c:url var="prevPageUrl" value="/projects">
        <c:param name="page" value="${projects.number - 1}" />
        <c:param name="size" value="${projects.size}" />
        <c:param name="sort" value="${empty param.sort ? 'id,desc' : param.sort}" />
        <c:param name="search" value="${search}" />
    </c:url>
    <c:url var="nextPageUrl" value="/projects">
        <c:param name="page" value="${projects.number + 1}" />
        <c:param name="size" value="${projects.size}" />
        <c:param name="sort" value="${empty param.sort ? 'id,desc' : param.sort}" />
        <c:param name="search" value="${search}" />
    </c:url>

    <nav aria-label="Projects pagination" class="d-flex align-items-center justify-content-between flex-wrap gap-3 mt-4">
        <div class="small text-muted">
            Showing ${projects.numberOfElements} of ${projects.totalElements} parent projects
        </div>
        <div class="d-flex align-items-center gap-2">
            <a class="btn btn-outline-secondary btn-sm ${projects.first ? 'disabled' : ''}"
                href="${projects.first ? '#' : prevPageUrl}"
                aria-label="Previous page">
                <i class="bi bi-chevron-left"></i>
                Previous
            </a>
            <span class="small text-muted px-2">
                Page ${projects.number + 1} of ${projects.totalPages}
            </span>
            <a class="btn btn-outline-secondary btn-sm ${projects.last ? 'disabled' : ''}"
                href="${projects.last ? '#' : nextPageUrl}"
                aria-label="Next page">
                Next
                <i class="bi bi-chevron-right"></i>
            </a>
        </div>
    </nav>
</c:if>

<sec:authorize access="hasAnyAuthority('ROLE_ADMIN', 'ROLE_SUPER_ADMIN')">
    <%@ include file="_create-modal.jsp" %>
    <%@ include file="_edit-modal.jsp" %>
</sec:authorize>

<script>
    (function () {
        document.querySelectorAll(".js-child-toggle").forEach(function (button) {
            button.addEventListener("click", function () {
                var parentId = button.getAttribute("data-parent-id");
                var rows = document.querySelectorAll(".project-child-of-" + parentId);
                var icon = button.querySelector(".js-child-toggle-icon");
                var expanded = button.getAttribute("aria-expanded") === "true";
                rows.forEach(function (row) {
                    row.classList.toggle("d-none", expanded);
                });
                button.setAttribute("aria-expanded", String(!expanded));
                if (icon) {
                    icon.classList.toggle("bi-chevron-right", expanded);
                    icon.classList.toggle("bi-chevron-down", !expanded);
                }
            });
        });

        var showCreateProjectModal = "${showCreateProjectModal}" === "true";
        if (showCreateProjectModal) {
            var el = document.getElementById("createProjectModal");
            if (el) new bootstrap.Modal(el).show();
        }
    })();
</script>

<%@ include file="../layout/footer.jsp" %>
