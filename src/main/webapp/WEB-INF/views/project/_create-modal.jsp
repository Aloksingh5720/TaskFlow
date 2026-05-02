<%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <c:set var="projectBinding"
        value="${requestScope['org.springframework.validation.BindingResult.createProjectForm']}" />
    <c:set var="modalId" value="${empty createProjectModalId ? 'createProjectModal' : createProjectModalId}" />

    <div class="modal fade" id="${modalId}" tabindex="-1" aria-labelledby="${modalId}Label" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content rounded-2">
                <form method="post" action="${pageContext.request.contextPath}/projects">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                    <div class="modal-header">
                        <div>
                            <h5 class="modal-title mb-1" id="${modalId}Label">Create Project</h5>
                            <p class="mb-0 text-muted small">Define project scope, hierarchy</p>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>

                    <div class="modal-body">
                        <div class="row g-3">

                            <div class="col-12">
                                <label for="${modalId}Name" class="form-label">Project Name</label>
                                <input id="${modalId}Name" name="name"
                                    class="form-control ${not empty projectBinding and projectBinding.hasFieldErrors('name') ? 'is-invalid' : ''}"
                                    required="true" placeholder="Enter project name"
                                    value="${createProjectForm.name}" />
                                <c:if test="${not empty projectBinding and projectBinding.hasFieldErrors('name')}">
                                    <div class="invalid-feedback">
                                        <c:forEach items="${projectBinding.getFieldErrors('name')}" var="error">
                                            <div>${error.defaultMessage}</div>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>

                            <div class="col-12">
                                <label for="${modalId}Description" class="form-label">Description</label>
                                <textarea id="${modalId}Description" name="description"
                                    class="form-control ${not empty projectBinding and projectBinding.hasFieldErrors('description') ? 'is-invalid' : ''}"
                                    rows="4" required="true"
                                    placeholder="Brief description of this project">${createProjectForm.description}</textarea>
                                <c:if
                                    test="${not empty projectBinding and projectBinding.hasFieldErrors('description')}">
                                    <div class="invalid-feedback">
                                        <c:forEach items="${projectBinding.getFieldErrors('description')}" var="error">
                                            <div>${error.defaultMessage}</div>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>

                            <c:choose>
                                <c:when
                                    test="${not empty project and not empty project.id and createProjectModalId == 'childProjectCreateModal'}">
                                    <div class="col-md-6">
                                        <label for="${modalId}ParentId" class="form-label">Parent Project</label>
                                        <input type="hidden" name="parentId" value="${project.id}" />
                                        <div class="form-control bg-light text-muted">${project.name}</div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="col-md-6">
                                        <label for="${modalId}ParentId" class="form-label">Parent Project</label>
                                        <select id="${modalId}ParentId" name="parentId" class="form-select">
                                            <option value="">None (Top-Level)</option>
                                            <c:forEach items="${parentProjects}" var="parentProject">
                                                <option value="${parentProject.id}"
                                                    ${createProjectForm.parentId==parentProject.id ? 'selected' : '' }>
                                                    ${parentProject.name}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <div class="col-md-6 d-flex align-items-end">
                                <p class="mb-0 text-muted small">
                                    <i class="bi bi-info-circle me-1"></i>
                                    Project status will default to <strong class="text-body">NOT STARTED</strong>.
                                </p>
                            </div>

                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg"></i>
                            Create Project
                        </button>
                    </div>

                </form>
            </div>
        </div>
    </div>