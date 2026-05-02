<%@ include file="../layout/header.jsp" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <div class="page-header mb-4">
            <h2 class="mb-1">${member.id == null ? 'Add Member' : 'Edit Member Roles'}</h2>
            <p class="text-muted mb-0">Project: <strong>${project.name}</strong></p>
        </div>

        <div class="section-card" style="max-width:560px">
            <form method="post"
                action="${pageContext.request.contextPath}/projects/${project.id}/members${member.id != null ? '/' : ''}${member.id != null ? member.id : ''}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <c:if test="${member.id == null}">
                    <div class="mb-4">
                        <label class="form-label">Select User</label>
                        <select name="userId" class="form-select" required>
                            <option value="">&mdash; Choose a user &mdash;</option>
                            <c:forEach items="${users}" var="user">
                                <option value="${user.id}">${user.username} (${user.email})</option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <div class="mb-4">
                    <label class="form-label">Project Role</label>
                    <div class="p-3 rounded"
                        style="background:var(--md-surface-container-low);border:1px solid var(--md-outline-variant)">
                        <div class="row g-2">
                            <c:forEach items="${roles}" var="role">
                                <div class="col-md-6">
                                    <div class="form-check">
                                        <input type="radio" name="roleId" value="${role.id}" class="form-check-input"
                                            ${member.roleId == role.id ? 'checked' : ''} required />
                                        <label class="form-check-label">${role.name}</label>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <div class="d-flex flex-wrap gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>${member.id == null ? 'Add Member' : 'Save Roles'}
                    </button>
                    <a href="${pageContext.request.contextPath}/projects/${project.id}/members"
                        class="btn btn-secondary">
                        <i class="bi bi-x-lg me-1"></i>Cancel
                    </a>
                </div>
            </form>
        </div>

        <%@ include file="../layout/footer.jsp" %>
