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
</div>

<c:if test="${not empty project}">
    <div class="section-card filter-panel mb-4">
        <div class="section-heading">
            <span class="section-label mb-0"><i class="bi bi-funnel me-1"></i>Filters</span>
            <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}" class="btn btn-sm btn-secondary">
                <i class="bi bi-x-circle"></i> Clear
            </a>
        </div>
        <form method="get" class="row g-3 align-items-end">
            <div class="col-lg-2 col-md-6">
                <label for="type" class="form-label">Type</label>
                <select name="type" id="type" class="form-select">
                    <option value="">All Types</option>
                    <c:forEach items="${types}" var="type">
                        <option value="${type.name()}" ${param.type == type.name() ? 'selected' : '' }>${fn:replace(type.name(), '_', ' ')}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-lg-2 col-md-6">
                <label for="status" class="form-label">Status</label>
                <select name="status" id="status" class="form-select">
                    <option value="">All Statuses</option>
                    <c:forEach items="${statuses}" var="status">
                        <option value="${status.name()}" ${param.status == status.name() ? 'selected' : '' }>${fn:replace(status.name(), '_', ' ')}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-lg-2 col-md-6">
                <label for="priority" class="form-label">Priority</label>
                <select name="priority" id="priority" class="form-select">
                    <option value="">All Priorities</option>
                    <c:forEach items="${priorities}" var="priority">
                        <option value="${priority.name()}" ${param.priority == priority.name() ? 'selected' : '' }>${fn:replace(priority.name(), '_', ' ')}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-lg-2 col-md-6">
                <label for="assigneeId" class="form-label">Assignee</label>
                <select name="assigneeId" id="assigneeId" class="form-select">
                    <option value="">All Assignees</option>
                    <c:forEach items="${users}" var="user">
                        <option value="${user.id}" ${param.assigneeId==user.id ? 'selected' : '' }>${user.username}</option>
                    </c:forEach>
                </select>
            </div>
        </form>
    </div>
</c:if>

<c:choose>
    <c:when test="${not empty project or title == 'Accountable Work Packages' or title == 'Overdue Work Packages'}">
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
                                </td>
                                <td class="table-cell-muted">${not empty wp.accountableUsername ? wp.accountableUsername : '—'}</td>
                                <td class="table-cell-muted">${not empty wp.assigneeUsername ? wp.assigneeUsername : '—'}</td>
                                <td class="table-cell-muted col-date">${not empty wp.dueDate ? wp.dueDate : '—'}</td>
                                <td class="pe-4 text-end">
                                    <div class="table-actions">
                                        <a href="${pageContext.request.contextPath}/work-packages/${wp.id}/edit" class="btn btn-sm btn-warning" title="Edit">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <c:if test="${(not empty project and showAdminOption) or (empty project and adminOptionByProjectId[wp.projectId])}">
                                            <form method="post" action="${pageContext.request.contextPath}/work-packages/${wp.id}/delete" class="d-inline mb-0"
                                                  onsubmit="return confirm('Are you sure you want to delete this work package?');">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                <button type="submit" class="btn btn-sm btn-danger" title="Delete">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
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
    </c:otherwise>
</c:choose>

<c:if test="${workPackages.totalPages > 1}">
    <nav aria-label="Work package pagination" class="mt-3">
        <ul class="pagination justify-content-end">
            <c:if test="${!workPackages.first}">
                <li class="page-item">
                    <a class="page-link" href="?page=${workPackages.number-1}&${queryString}">
                        <i class="bi bi-chevron-left"></i>
                    </a>
                </li>
            </c:if>
            <c:forEach begin="0" end="${workPackages.totalPages-1}" var="i">
                <li class="page-item ${i == workPackages.number ? 'active' : ''}">
                    <a class="page-link" href="?page=${i}&${queryString}">${i+1}</a>
                </li>
            </c:forEach>
            <c:if test="${!workPackages.last}">
                <li class="page-item">
                    <a class="page-link" href="?page=${workPackages.number+1}&${queryString}">
                        <i class="bi bi-chevron-right"></i>
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>
</c:if>

<%@ include file="../layout/footer.jsp" %>
