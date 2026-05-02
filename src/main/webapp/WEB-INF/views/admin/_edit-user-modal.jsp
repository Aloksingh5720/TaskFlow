<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<c:set var="editUserBinding" value="${requestScope['org.springframework.validation.BindingResult.editUser']}" />

<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2">
            <form:form method="post" modelAttribute="editUser" id="editUserForm"
                action="${pageContext.request.contextPath}/admin/users/${editUser.id}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" name="page" value="${currentPage}" />
                <input type="hidden" name="sortField" value="${sortField}" />
                <input type="hidden" name="sortDir" value="${sortDir}" />
                <input type="hidden" name="search" value="${search}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="editUserModalLabel">Edit User</h5>
                        <p class="mb-0 text-muted small">Update account details and role assignment.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <c:if test="${not empty editUserBinding and editUserBinding.errorCount > 0}">
                        <div class="alert alert-danger py-2" role="alert">
                            <form:errors path="*" element="div" />
                        </div>
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <form:label path="username" class="form-label">Username *</form:label>
                            <form:input path="username" id="editUserUsername"
                                class="form-control ${not empty editUserBinding and editUserBinding.hasFieldErrors('username') ? 'is-invalid' : ''}"
                                required="true" placeholder="username" />
                            <form:errors path="username" cssClass="invalid-feedback d-block" />
                        </div>

                        <div class="col-md-6">
                            <form:label path="name" class="form-label">Display Name *</form:label>
                            <form:input path="name" id="editUserName"
                                class="form-control ${not empty editUserBinding and editUserBinding.hasFieldErrors('name') ? 'is-invalid' : ''}"
                                required="true" placeholder="Full name" />
                            <form:errors path="name" cssClass="invalid-feedback d-block" />
                        </div>

                        <div class="col-12">
                            <form:label path="email" class="form-label">Email *</form:label>
                            <form:input path="email" id="editUserEmail" type="email"
                                class="form-control ${not empty editUserBinding and editUserBinding.hasFieldErrors('email') ? 'is-invalid' : ''}"
                                required="true" placeholder="user@example.com" />
                            <form:errors path="email" cssClass="invalid-feedback d-block" />
                        </div>

                        <div class="col-12">
                            <form:label path="password" class="form-label">Password</form:label>
                            <form:password path="password" id="editUserPassword"
                                class="form-control ${not empty editUserBinding and editUserBinding.hasFieldErrors('password') ? 'is-invalid' : ''}"
                                placeholder="Leave blank to keep current password" />
                            <form:errors path="password" cssClass="invalid-feedback d-block" />
                            <small class="form-text" style="color:var(--md-on-surface-variant)">Leave blank to keep
                                the current password.</small>
                        </div>

                        <div class="col-12">
                            <div class="p-3 rounded"
                                style="background:var(--md-surface-container-low);border:1px solid var(--md-outline-variant)">
                                <div class="form-check mb-0">
                                    <form:checkbox path="enabled" class="form-check-input" id="editUserEnabled" />
                                    <form:label path="enabled" class="form-check-label" for="editUserEnabled">
                                        <strong>Account Enabled</strong>
                                    </form:label>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Global Role *</label>
                            <div class="row g-2">
                                <c:forEach items="${roles}" var="role">
                                    <div class="col-md-4 col-sm-6">
                                        <div class="form-check">
                                            <input type="radio" name="globalRoleId" value="${role.id}"
                                                id="editUserRole${role.id}"
                                                class="form-check-input ${not empty editUserBinding and editUserBinding.hasFieldErrors('globalRoleId') ? 'is-invalid' : ''}"
                                                ${editUser.globalRoleId == role.id ? 'checked' : ''} required />
                                            <label class="form-check-label" for="editUserRole${role.id}">${role.name}</label>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            <form:errors path="globalRoleId" cssClass="invalid-feedback d-block mt-1" />
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg"></i>
                        Save Changes
                    </button>
                </div>
            </form:form>
        </div>
    </div>
</div>
