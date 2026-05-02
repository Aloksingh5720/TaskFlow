<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    .table-responsive,
    .table-shell {
        overflow: visible;
    }

    .wp-inline-dropdown .dropdown-menu {
        z-index: 1050;
    }
</style>

<c:set var="activeFilterCount" value="0" />
<c:if test="${not empty param.search}"><c:set var="activeFilterCount" value="${activeFilterCount + 1}" /></c:if>
<c:if test="${not empty param.type}"><c:set var="activeFilterCount" value="${activeFilterCount + 1}" /></c:if>
<c:if test="${not empty param.status}"><c:set var="activeFilterCount" value="${activeFilterCount + 1}" /></c:if>
<c:if test="${not empty param.priority}"><c:set var="activeFilterCount" value="${activeFilterCount + 1}" /></c:if>
<c:if test="${not empty param.assigneeId}"><c:set var="activeFilterCount" value="${activeFilterCount + 1}" /></c:if>

<div class="view-toolbar page-header mb-3">
    <div>
        <c:choose>
            <c:when test="${not empty project}">
                <h2 class="mb-1">Work Packages &mdash; ${project.name}</h2>
                <p class="text-muted mb-0">Track delivery and execution for this project.</p>
            </c:when>
            <c:otherwise>
                <h2 class="mb-1">${title != null ? title : 'Work Packages'}</h2>
                <p class="text-muted mb-0">Monitor assignments, ownership, and execution status.</p>
            </c:otherwise>
        </c:choose>
    </div>
    <div class="toolbar-actions">
        <c:if test="${not empty project}">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createWorkPackageModal">
                <i class="bi bi-plus-lg"></i> New Work Package
            </button>
            <a href="${pageContext.request.contextPath}/projects/${project.id}" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Project
            </a>
        </c:if>
    </div>
</div>

<c:if test="${not empty project}">
    <div class="search-container">
        <div class="search-container__header">
            <span class="search-container__label">
                <i class="bi bi-funnel"></i>Filters & Search
                <c:if test="${activeFilterCount > 0}">
                    <span class="search-container__badge">${activeFilterCount}</span>
                </c:if>
            </span>
            <div class="search-container__actions">
                <c:if test="${activeFilterCount > 0}">
                    <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}" class="btn btn-sm btn-outline-light">
                        <i class="bi bi-x-circle"></i> Clear All
                    </a>
                </c:if>
            </div>
        </div>
        <form method="get" class="search-container__form">
            <input type="hidden" name="projectId" value="${project.id}" />
            <div class="search-container__row">
                <div class="search-container__group" style="max-width: 440px;">
                    <div class="search-container__label-field">
                        <label for="search" class="form-label">Search</label>
                        <div class="search-input-wrapper">
                            <i class="bi bi-search search-input-icon"></i>
                            <input type="text" name="search" id="search" value="${search}" class="search-input"
                                placeholder="Search by work package ID or subject" />
                            <c:if test="${not empty search}">
                                <button type="button" class="search-input-clear" onclick="document.getElementById('search').value='';this.parentElement.querySelector('form').submit();">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </c:if>
                        </div>
                    </div>
                </div>
                <div class="search-container__group search-container__group--small">
                    <div class="search-container__label-field">
                        <label for="type" class="form-label">Type</label>
                        <select name="type" id="type" class="form-control form-select">
                            <option value="">All Types</option>
                            <c:forEach items="${types}" var="type">
                                <option value="${type.name()}" ${param.type == type.name() ? 'selected' : '' }>${fn:replace(type.name(), '_', ' ')}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="search-container__group search-container__group--small">
                    <div class="search-container__label-field">
                        <label for="status" class="form-label">Status</label>
                        <select name="status" id="status" class="form-control form-select">
                            <option value="">All Statuses</option>
                            <c:forEach items="${statuses}" var="status">
                                <option value="${status.name()}" ${param.status == status.name() ? 'selected' : '' }>${fn:replace(status.name(), '_', ' ')}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="search-container__group search-container__group--small">
                    <div class="search-container__label-field">
                        <label for="priority" class="form-label">Priority</label>
                        <select name="priority" id="priority" class="form-control form-select">
                            <option value="">All Priorities</option>
                            <c:forEach items="${priorities}" var="priority">
                                <option value="${priority.name()}" ${param.priority == priority.name() ? 'selected' : '' }>${fn:replace(priority.name(), '_', ' ')}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="search-container__group" style="flex: 0 0 auto; min-width: auto;">
                    <div class="search-container__label-field">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary search-btn">
                            <i class="bi bi-search"></i> Search
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</c:if>

<c:choose>
    <c:when test="${not empty project or title == 'My Work Packages' or title == 'Overdue Work Packages'}">
        <div class="table-shell table-shell--spacious">
            <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 workpackage-table">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4 py-3 fw-medium text-muted small text-uppercase border-bottom col-id">ID</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Subject</th>
                            <c:if test="${empty project}">
                                <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Project</th>
                            </c:if>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Type</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Status</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Priority</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Accountable</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom">Assignee</th>
                            <th class="py-3 fw-medium text-muted small text-uppercase border-bottom col-date">Expected Date</th>
                            <th class="pe-4 py-3 fw-medium text-muted small text-uppercase border-bottom text-end col-actions">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${workPackages.content}" var="wp">
                            <c:set var="canChangeThisWorkPackageClassification"
                                value="${canChangeWorkPackageClassification or (currentUserId != null and wp.accountableId == currentUserId)}" />
                            <tr>
                                <td class="ps-4 py-3 text-muted small fw-semibold workpackage-id-cell">${not empty wp.uiId ? wp.uiId : wp.id}</td>
                                <td class="workpackage-subject">
                                    <a href="${pageContext.request.contextPath}/work-packages/${wp.id}" title="${wp.subject}">${wp.subject}</a>
                                </td>
                                <c:if test="${empty project}">
                                    <td class="table-cell-muted">
                                        <a href="${pageContext.request.contextPath}/projects/${wp.projectId}">${wp.projectName}</a>
                                    </td>
                                </c:if>
                                <td class="wp-inline-edit-cell">
                                    <c:choose>
                                        <c:when test="${canChangeThisWorkPackageClassification}">
                                            <div class="dropdown wp-inline-dropdown">
                                                <button class="btn btn-sm btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    ${fn:replace(wp.workPackageType.name(), '_', ' ')}
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <c:forEach items="${types}" var="type">
                                                        <c:if test="${wp.workPackageType != type}">
                                                            <li>
                                                                <form method="post" action="${pageContext.request.contextPath}/work-packages/${wp.id}/quick-update" class="mb-0">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                    <input type="hidden" name="type" value="${type.name()}" />
                                                                    <input type="hidden" name="status" value="${wp.workPackageStatus.name()}" />
                                                                    <input type="hidden" name="priority" value="${wp.workPackagePriority.name()}" />
                                                                    <button class="dropdown-item" type="submit">${fn:replace(type.name(), '_', ' ')}</button>
                                                                </form>
                                                            </li>
                                                        </c:if>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="table-cell-muted">${fn:replace(wp.workPackageType.name(), '_', ' ')}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="wp-inline-edit-cell">
                                    <div class="dropdown wp-inline-dropdown">
                                        <c:choose>
                                            <c:when test="${wp.workPackageStatus.name() == 'DONE' || wp.workPackageStatus.name() == 'CLOSED'}">
                                                <c:set var="wpStatusBtnClass" value="btn-success" />
                                            </c:when>
                                            <c:when test="${wp.workPackageStatus.name() == 'IN_PROGRESS' || wp.workPackageStatus.name() == 'IN_REVIEW'}">
                                                <c:set var="wpStatusBtnClass" value="btn-warning" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="wpStatusBtnClass" value="btn-secondary" />
                                            </c:otherwise>
                                        </c:choose>
                                        <button class="btn btn-sm ${wpStatusBtnClass} dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            ${fn:replace(wp.workPackageStatus.name(), '_', ' ')}
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <c:forEach items="${statuses}" var="status">
                                                <c:if test="${wp.workPackageStatus != status}">
                                                    <li>
                                                        <form method="post" action="${pageContext.request.contextPath}/work-packages/${wp.id}/quick-update" class="mb-0">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                            <input type="hidden" name="type" value="${wp.workPackageType.name()}" />
                                                            <input type="hidden" name="status" value="${status.name()}" />
                                                            <input type="hidden" name="priority" value="${wp.workPackagePriority.name()}" />
                                                            <button class="dropdown-item" type="submit">${fn:replace(status.name(), '_', ' ')}</button>
                                                        </form>
                                                    </li>
                                                </c:if>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </td>
                                <td class="wp-inline-edit-cell">
                                    <c:choose>
                                        <c:when test="${canChangeThisWorkPackageClassification}">
                                            <div class="dropdown wp-inline-dropdown">
                                                <c:choose>
                                                    <c:when test="${wp.workPackagePriority.name() == 'HIGH' || wp.workPackagePriority.name() == 'CRITICAL'}">
                                                        <c:set var="wpPriorityBtnClass" value="btn-danger" />
                                                    </c:when>
                                                    <c:when test="${wp.workPackagePriority.name() == 'LOW'}">
                                                        <c:set var="wpPriorityBtnClass" value="btn-secondary" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set var="wpPriorityBtnClass" value="btn-warning" />
                                                    </c:otherwise>
                                                </c:choose>
                                                <button class="btn btn-sm ${wpPriorityBtnClass} dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    ${fn:replace(wp.workPackagePriority.name(), '_', ' ')}
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <c:forEach items="${priorities}" var="priority">
                                                        <c:if test="${wp.workPackagePriority != priority}">
                                                            <li>
                                                                <form method="post" action="${pageContext.request.contextPath}/work-packages/${wp.id}/quick-update" class="mb-0">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                    <input type="hidden" name="type" value="${wp.workPackageType.name()}" />
                                                                    <input type="hidden" name="status" value="${wp.workPackageStatus.name()}" />
                                                                    <input type="hidden" name="priority" value="${priority.name()}" />
                                                                    <button class="dropdown-item" type="submit">${fn:replace(priority.name(), '_', ' ')}</button>
                                                                </form>
                                                            </li>
                                                        </c:if>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="table-cell-muted">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="table-cell-muted">${not empty wp.accountableUsername ? wp.accountableUsername : '—'}</td>
                                <td class="table-cell-muted">${not empty wp.assigneeUsername ? wp.assigneeUsername : '—'}</td>
                                <td class="table-cell-muted col-date">${not empty wp.dueDate ? wp.dueDate : '—'}</td>
                                <td class="pe-4 text-end">
                                    <div class="table-actions">
                                        <c:if test="${canChangeThisWorkPackageClassification}">
                                            <a href="${pageContext.request.contextPath}/work-packages/${wp.id}/edit" class="btn btn-sm btn-warning" title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                        </c:if>
                                        <c:if test="${(not empty project and showAdminOption) or (empty project and adminOptionByProjectId[wp.projectId])}">
                                            <button type="button" class="btn btn-sm btn-danger" title="Delete"
                                                data-bs-toggle="modal" data-bs-target="#deleteConfirmModal"
                                                data-delete-action="${pageContext.request.contextPath}/work-packages/${wp.id}/delete"
                                                data-delete-message="Are you sure you want to delete work package ${not empty wp.uiId ? wp.uiId : wp.id} '${wp.subject}'? This action cannot be undone.">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty workPackages.content}">
                            <tr>
                                <td colspan="${empty project ? 10 : 9}">
                                    <div class="empty-state">
                                        <i class="bi bi-inbox"></i>
                                        <p>No work packages found.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </c:when>
    <c:otherwise>
        <c:if test="${empty workPackages.content}">
            <div class="section-card empty-state">
                <i class="bi bi-inbox"></i>
                <p>No work packages found.</p>
            </div>
        </c:if>
        <c:if test="${not empty workPackages.content}">
            <div class="kanban-board-wrap all-packages-kanban">
                <div class="kanban-board compact">
                    <c:set var="processedProjectIds" value="," />
                    <c:forEach items="${workPackages.content}" var="groupSeed">
                        <c:set var="projectMarker" value=",${groupSeed.projectId}," />
                        <c:if test="${not fn:contains(processedProjectIds, projectMarker)}">
                            <section class="kanban-column">
                                <header class="kanban-column-header">
                                    <div class="d-flex align-items-center gap-2">
                                        <h6 class="kanban-column-title mb-0"><i class="bi bi-folder2-open me-1"></i>${groupSeed.projectName}</h6>
                                        <span class="kanban-column-count">
                                            <c:set var="projectCount" value="0" />
                                            <c:forEach items="${workPackages.content}" var="countWp">
                                                <c:if test="${countWp.projectId == groupSeed.projectId}"><c:set var="projectCount" value="${projectCount + 1}" /></c:if>
                                            </c:forEach>
                                            ${projectCount}
                                        </span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/work-packages/project/${groupSeed.projectId}" class="btn btn-sm btn-secondary">Open</a>
                                </header>
                                <div class="kanban-column-body">
                                    <c:forEach items="${workPackages.content}" var="wp">
                                        <c:if test="${wp.projectId == groupSeed.projectId}">
                                            <article class="kanban-card">
                                                <div class="kanban-card-top">
                                                    <span class="kanban-card-id">${not empty wp.uiId ? wp.uiId : wp.id}</span>
                                                    <span class="chip chip-secondary">${fn:replace(wp.workPackageStatus.name(), '_', ' ')}</span>
                                                </div>
                                                <h6 class="mb-1">
                                                    <a href="${pageContext.request.contextPath}/work-packages/${wp.id}" class="kanban-card-title">${wp.subject}</a>
                                                </h6>
                                                <p class="kanban-card-description">${wp.description}</p>
                                                <div class="kanban-card-meta">
                                                    <span class="chip chip-surface">${fn:replace(wp.workPackageType.name(), '_', ' ')}</span>
                                                    <c:choose>
                                                        <c:when test="${wp.workPackagePriority.name() == 'HIGH' || wp.workPackagePriority.name() == 'CRITICAL'}"><span class="chip chip-error">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span></c:when>
                                                        <c:when test="${wp.workPackagePriority.name() == 'LOW'}"><span class="chip chip-surface">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span></c:when>
                                                        <c:otherwise><span class="chip chip-warning">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="kanban-card-info">
                                                    <span><i class="bi bi-person"></i>${not empty wp.assigneeName ? wp.assigneeName : 'Unassigned'}</span>
                                                    <span><i class="bi bi-calendar-event"></i>${not empty wp.dueDate ? wp.dueDate : 'No due date'}</span>
                                                </div>
                                            </article>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </section>
                            <c:set var="processedProjectIds" value="${processedProjectIds}${groupSeed.projectId}," />
                        </c:if>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>

<c:if test="${not empty project}">
    <%@ include file="_create-modal.jsp" %>
</c:if>

<c:if test="${workPackages.totalPages > 1}">
    <nav aria-label="Work package pagination" class="d-flex align-items-center justify-content-between flex-wrap gap-3 mt-3">
        <div class="small text-muted">
            Showing ${workPackages.numberOfElements} of ${workPackages.totalElements} work packages
        </div>
        <div class="d-flex align-items-center gap-2">
            <a class="btn btn-outline-secondary btn-sm ${workPackages.first ? 'disabled' : ''}"
                href="?page=${workPackages.number-1}${not empty queryString ? '&' : ''}${queryString}"
                aria-label="Previous page">
                <i class="bi bi-chevron-left"></i>
                Previous
            </a>
            <span class="small text-muted px-2">
                Page ${workPackages.number + 1} of ${workPackages.totalPages}
            </span>
            <a class="btn btn-outline-secondary btn-sm ${workPackages.last ? 'disabled' : ''}"
                href="?page=${workPackages.number+1}${not empty queryString ? '&' : ''}${queryString}"
                aria-label="Next page">
                Next
                <i class="bi bi-chevron-right"></i>
            </a>
        </div>
    </nav>
</c:if>

<%@ include file="../issue/_create-modal.jsp" %>
<%@ include file="../layout/footer.jsp" %>
