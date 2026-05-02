<%@include file="../layout/header.jsp" %> <%@ taglib prefix="c" uri="jakarta.tags.core" %> <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %> <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    .table-responsive,
    .table-shell {
        overflow: visible;
    }

    .wp-inline-dropdown .dropdown-menu {
        z-index: 1050;
    }
</style>
<div class="mb-3 page-header view-toolbar">
    <div>
        <c:choose>
            <c:when test="${not empty project}">
                <h2 class="mb-1">Work Packages — ${project.name}</h2>
                <p class="mb-0 text-muted">Track delivery and execution for this project.</p>
            </c:when>
            <c:otherwise>
                <h2 class="mb-1">${title != null ? title : 'Work Packages'}</h2>
                <p class="mb-0 text-muted">Monitor your assignments, ownership, and execution status.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<c:choose>
    <c:when test="${not empty project or title == 'Assigned Work Packages'}">
        <div class="table-shell table-shell--spacious">
            <div class="table-responsive">
                <table class="mb-0 align-middle table table-hover workpackage-table">
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
                            <th class="pe-4 py-3 fw-medium text-muted small text-uppercase border-bottom text-end col-actions">Issue</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="wp" items="${workPackages.content}">
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
                                <td class="table-cell-muted">${fn:replace (wp.workPackageType.name(), '_', ' ')}</td>
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
                                            <c:forEach var="status" items="${statuses}">
                                                <c:if test="${wp.workPackageStatus != status}">
                                                    <li>
                                                        <form action="${pageContext.request.contextPath}/work-packages/${wp.id}/quick-update" class="mb-0" method="post">
                                                            <input name="${_csrf.parameterName}" type="hidden" value="${_csrf.token}" />
                                                            <input name="type" type="hidden" value="${wp.workPackageType.name()}" />
                                                            <input name="priority" type="hidden" value="${wp.workPackagePriority.name()}" />
                                                            <input name="status" type="hidden" value="${status.name()}" />
                                                            <button class="dropdown-item" type="submit">${fn:replace(status.name(), '_', ' ')}</button>
                                                        </form>
                                                    </li>
                                                </c:if>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </td>
                                <td class="table-cell-muted">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</td>
                                <td class="table-cell-muted">${not empty wp.accountableUsername ? wp.accountableUsername : '—'}</td>
                                <td class="table-cell-muted">${not empty wp.assigneeUsername ? wp.assigneeUsername : '—'}</td>
                                <td class="table-cell-muted col-date">${not empty wp.dueDate ? wp.dueDate : '—'}</td>
                                <td class="pe-4 text-end">
                                    <button type="button" class="bg-danger border border-danger btn btn-sm px-3 rounded-pill shadow-sm text-white" title="Raise Issue"
                                        data-bs-toggle="modal" data-bs-target="#createIssueModal"
                                        data-issue-action="${pageContext.request.contextPath}/work-packages/${wp.id}/issue">
                                        <i class="bi bi-flag me-1"></i> Issue
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty workPackages.content}">
                            <tr>
                                <td colspan="${empty project ? 11 : 10}">
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
            <div class="empty-state section-card">
                <i class="bi bi-inbox"></i>
                <p>No work packages found.</p>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>
<c:if test="${workPackages.totalPages > 1}">
    <nav aria-label="Work package pagination" class="mt-3">
        <ul class="justify-content-end pagination">
            <c:if test="${!workPackages.first}">
                <li class="page-item">
                    <a href="?page=${workPackages.number-1}&${queryString}" class="page-link">
                        <i class="bi bi-chevron-left"></i>
                    </a>
                </li>
            </c:if>
            <c:forEach var="i" begin="0" end="${workPackages.totalPages-1}">
                <li class="page-item ${i == workPackages.number ? 'active' : ''}">
                    <a href="?page=${i}&${queryString}" class="page-link">${i+1}</a>
                </li>
            </c:forEach>
            <c:if test="${!workPackages.last}">
                <li class="page-item">
                    <a href="?page=${workPackages.number+1}&${queryString}" class="page-link">
                        <i class="bi bi-chevron-right"></i>
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>
</c:if>
<%@ include file="../issue/_create-modal.jsp" %>
<%@ include file="../layout/footer.jsp" %>
