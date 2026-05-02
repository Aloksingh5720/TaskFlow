<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="view-toolbar page-header mb-4">
    <div>
        <h2 class="mb-1">Issues</h2>
        <p class="text-muted mb-0">Track and manage issues on work packages.</p>
    </div>
</div>

<div class="row g-4">
    <!-- Issues to Resolve -->
    <div class="col-lg-6">
        <div class="section-card h-100">
            <div class="section-heading mb-3">
                <h5 class="section-label mb-0"><i class="bi bi-check-circle me-1"></i>Issues to Resolve</h5>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Issue</th>
                            <th>Work Package</th>
                            <th>Status</th>
                            <th class="col-actions">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${toResolveIssues.content}" var="issue">
                            <tr>
                                <td>
                                    <div class="fw-bold text-truncate" style="max-width: 150px;" title="${issue.title}">${issue.title}</div>
                                    <small class="text-muted">#${issue.id}</small>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/work-packages/${issue.workPackageId}" class="text-decoration-none">
                                        ${issue.workPackageName}
                                    </a>
                                </td>
                                <td>
                                    <span class="chip ${issue.issueStatus.name() == 'RESOLVED' ? 'chip-success' : 'chip-warning'}">
                                        ${fn:replace(issue.issueStatus.name(), '_', ' ')}
                                    </span>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <button type="button" class="btn btn-sm btn-info" title="View Issue Details"
                                                data-bs-toggle="modal" data-bs-target="#issueDetailModal"
                                                data-title="${issue.title}" data-description="${issue.description}">
                                            <i class="bi bi-info-circle text-white"></i>
                                        </button>
                                        <c:if test="${issue.issueStatus.name() != 'RESOLVED' && issue.accountableId == currentUserId}">
                                            <form action="${pageContext.request.contextPath}/issues/${issue.id}/resolve" method="post" class="d-inline">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                <button type="submit" class="btn btn-sm btn-success" title="Mark as Resolved">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty toResolveIssues.content}">
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state py-4 text-center">
                                        <i class="bi bi-journal-check mb-2 d-block empty-state-icon"></i>
                                        <p class="text-muted mb-0 small">No issues assigned to you.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Issues Raised by Me -->
    <div class="col-lg-6">
        <div class="section-card h-100">
            <div class="section-heading mb-3">
                <h5 class="section-label mb-0"><i class="bi bi-exclamation-diamond me-1"></i>Issues Raised by Me</h5>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Issue</th>
                            <th>Work Package</th>
                            <th>Status</th>
                            <th class="col-actions">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${raisedIssues.content}" var="issue">
                            <tr>
                                <td>
                                    <div class="fw-bold text-truncate" style="max-width: 150px;" title="${issue.title}">${issue.title}</div>
                                    <small class="text-muted">#${issue.id}</small>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/work-packages/${issue.workPackageId}" class="text-decoration-none">
                                        ${issue.workPackageName}
                                    </a>
                                </td>
                                <td>
                                    <span class="chip ${issue.issueStatus.name() == 'RESOLVED' ? 'chip-success' : 'chip-warning'}">
                                        ${fn:replace(issue.issueStatus.name(), '_', ' ')}
                                    </span>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <button type="button" class="btn btn-sm btn-info" title="View Issue Details"
                                                data-bs-toggle="modal" data-bs-target="#issueDetailModal"
                                                data-title="${issue.title}" data-description="${issue.description}">
                                            <i class="bi bi-info-circle text-white"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty raisedIssues.content}">
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state py-4 text-center">
                                        <i class="bi bi-megaphone mb-2 d-block empty-state-icon"></i>
                                        <p class="text-muted mb-0 small">You haven't raised any issues.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Issue Detail Modal -->
<div class="modal fade" id="issueDetailModal" tabindex="-1" aria-labelledby="issueDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header bg-light">
        <h5 class="modal-title" id="issueDetailModalLabel"><i class="bi bi-info-circle me-2"></i>Issue Details</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-4">
        <div class="mb-4">
            <label class="text-label-sm">Title</label>
            <h5 id="modalIssueTitle" class="mb-0"></h5>
        </div>
        <hr class="my-3 opacity-10">
        <div>
            <label class="text-label-sm">Description</label>
            <p id="modalIssueDescription" class="mb-0 text-prewrap"></p>
        </div>
      </div>
      <div class="modal-footer border-0">
        <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var issueDetailModal = document.getElementById('issueDetailModal');
        if (issueDetailModal) {
            issueDetailModal.addEventListener('show.bs.modal', function (event) {
                var button = event.relatedTarget;
                var title = button.getAttribute('data-title');
                var description = button.getAttribute('data-description');
                
                var modalTitle = issueDetailModal.querySelector('#modalIssueTitle');
                var modalDescription = issueDetailModal.querySelector('#modalIssueDescription');

                if (modalTitle) modalTitle.textContent = title;
                if (modalDescription) modalDescription.textContent = description;
            });
        }
    });
</script>

<%@ include file="../layout/footer.jsp" %>
