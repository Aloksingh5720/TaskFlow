<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="addMemberModal" tabindex="-1" aria-labelledby="addMemberModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-2">
            <form method="post" action="${pageContext.request.contextPath}/projects/${project.id}/members">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="addMemberModalLabel">Add Member</h5>
                        <p class="mb-0 text-muted small">Add a user to project <strong>${project.name}</strong>.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label for="addMemberUserId" class="form-label">Select User *</label>
                            <select name="userId" id="addMemberUserId" class="form-select" required>
                                <option value="">&mdash; Choose a user &mdash;</option>
                                <c:forEach items="${availableUsers}" var="user">
                                    <option value="${user.id}">${user.username} (${user.email})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Project Role *</label>
                            <div class="p-3 rounded"
                                style="background:var(--md-surface-container-low);border:1px solid var(--md-outline-variant)">
                                <div class="row g-2">
                                    <c:forEach items="${roles}" var="role">
                                        <div class="col-md-6">
                                            <div class="form-check">
                                                <input type="radio" name="roleId" value="${role.id}"
                                                    class="form-check-input" id="addMemberRole${role.id}" required />
                                                <label class="form-check-label" for="addMemberRole${role.id}">${role.name}</label>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-person-plus me-1"></i>Add Member
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
