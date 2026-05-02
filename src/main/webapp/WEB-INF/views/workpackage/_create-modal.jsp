<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="workPackageBinding"
    value="${requestScope['org.springframework.validation.BindingResult.createWorkPackageForm']}" />
<c:set var="workPackageModalId"
    value="${empty createWorkPackageModalId ? 'createWorkPackageModal' : createWorkPackageModalId}" />
<c:set var="workPackageRedirectPath"
    value="${pageContext.request.requestURI}${not empty pageContext.request.queryString ? '?' : ''}${not empty pageContext.request.queryString ? pageContext.request.queryString : ''}" />

<div class="modal fade" id="${workPackageModalId}" tabindex="-1" aria-labelledby="${workPackageModalId}Label" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl">
        <div class="modal-content rounded-2">
            <form method="post" action="${pageContext.request.contextPath}/work-packages">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" name="redirectPath" value="${workPackageRedirectPath}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="${workPackageModalId}Label">Create Work Package</h5>
                        <p class="mb-0 text-muted small">Capture task details, ownership, and delivery timeline.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">
                        <c:choose>
                            <c:when test="${not empty project and not empty project.id}">
                                <input type="hidden" name="projectId" value="${project.id}" />
                                <div class="col-12">
                                    <label class="form-label">Project</label>
                                    <div class="form-control bg-light text-muted">${project.name}</div>
                                </div>
                            </c:when>
                            <c:when test="${not empty selectedProjectId}">
                                <input type="hidden" name="projectId" value="${selectedProjectId}" />
                                <div class="col-12">
                                    <label class="form-label">Project</label>
                                    <div class="form-control bg-light text-muted">
                                        <c:forEach items="${projects}" var="projectOption">
                                            <c:if test="${projectOption.id == selectedProjectId}">
                                                ${projectOption.name}
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="col-md-6">
                                    <label for="${workPackageModalId}ProjectId" class="form-label">Project *</label>
                                    <select id="${workPackageModalId}ProjectId" name="projectId"
                                        class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('projectId') ? 'is-invalid' : ''}" required="true">
                                        <option value="">-- Select Project --</option>
                                        <c:forEach items="${projects}" var="projectOption">
                                            <option value="${projectOption.id}" ${createWorkPackageForm.projectId == projectOption.id ? 'selected' : ''}>
                                                ${projectOption.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('projectId')}">
                                        <div class="invalid-feedback">
                                            <c:forEach items="${workPackageBinding.getFieldErrors('projectId')}" var="error">
                                                <div>${error.defaultMessage}</div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <div class="col-md-4">
                            <label for="${workPackageModalId}Type" class="form-label">Type *</label>
                            <select id="${workPackageModalId}Type" name="workPackageType"
                                class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackageType') ? 'is-invalid' : ''}" required="true">
                                <option value="">-- Select Type --</option>
                                <c:forEach items="${types}" var="type">
                                    <option value="${type.name()}" ${createWorkPackageForm.workPackageType == type ? 'selected' : ''}>
                                        ${fn:replace(type.name(), '_', ' ')}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackageType')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('workPackageType')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="${workPackageModalId}Status" class="form-label">Status *</label>
                            <select id="${workPackageModalId}Status" name="workPackageStatus"
                                class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackageStatus') ? 'is-invalid' : ''}" required="true">
                                <option value="">-- Select Status --</option>
                                <c:forEach items="${statuses}" var="status">
                                    <option value="${status.name()}" ${createWorkPackageForm.workPackageStatus == status ? 'selected' : ''}>
                                        ${fn:replace(status.name(), '_', ' ')}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackageStatus')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('workPackageStatus')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="${workPackageModalId}Priority" class="form-label">Priority *</label>
                            <select id="${workPackageModalId}Priority" name="workPackagePriority"
                                class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackagePriority') ? 'is-invalid' : ''}" required="true">
                                <option value="">-- Select Priority --</option>
                                <c:forEach items="${priorities}" var="priority">
                                    <option value="${priority.name()}" ${createWorkPackageForm.workPackagePriority == priority ? 'selected' : ''}>
                                        ${fn:replace(priority.name(), '_', ' ')}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('workPackagePriority')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('workPackagePriority')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-12">
                            <label for="${workPackageModalId}Subject" class="form-label">Subject *</label>
                            <input id="${workPackageModalId}Subject" name="subject"
                                class="form-control ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('subject') ? 'is-invalid' : ''}"
                                required="true" placeholder="Short descriptive title" value="${createWorkPackageForm.subject}" />
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('subject')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('subject')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-12">
                            <label for="${workPackageModalId}Description" class="form-label">Description *</label>
                            <textarea id="${workPackageModalId}Description" name="description"
                                class="form-control ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('description') ? 'is-invalid' : ''}"
                                rows="5" required="true" placeholder="Detailed description, acceptance criteria, etc.">${createWorkPackageForm.description}</textarea>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('description')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('description')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-3">
                            <label for="${workPackageModalId}Accountable" class="form-label">Accountable</label>
                            <select id="${workPackageModalId}Accountable" name="accountableId"
                                class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('accountableId') ? 'is-invalid' : ''}">
                                <option value="">-- Not Set --</option>
                                <c:forEach items="${workPackageMembers}" var="member">
                                    <option value="${member.userId}" ${createWorkPackageForm.accountableId == member.userId ? 'selected' : ''}>
                                        ${member.username}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('accountableId')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('accountableId')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-3">
                            <label for="${workPackageModalId}Assignee" class="form-label">Assignee</label>
                            <select id="${workPackageModalId}Assignee" name="assigneeId"
                                class="form-select ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('assigneeId') ? 'is-invalid' : ''}">
                                <option value="">-- Unassigned --</option>
                                <c:forEach items="${workPackageMembers}" var="member">
                                    <option value="${member.userId}" ${createWorkPackageForm.assigneeId == member.userId ? 'selected' : ''}>
                                        ${member.username}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('assigneeId')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('assigneeId')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-3">
                            <label for="${workPackageModalId}DueDate" class="form-label">Due Date</label>
                            <input id="${workPackageModalId}DueDate" type="date" name="dueDate" class="form-control"
                                value="${createWorkPackageForm.dueDate}" />
                        </div>

                        <div class="col-md-3">
                            <label for="${workPackageModalId}EstimatedHours" class="form-label">Estimated Hours *</label>
                            <input id="${workPackageModalId}EstimatedHours" type="number" step="0.50" min="0.50" name="estimatedHours"
                                class="form-control ${not empty workPackageBinding and workPackageBinding.hasFieldErrors('estimatedHours') ? 'is-invalid' : ''}"
                                placeholder="0.00" value="${createWorkPackageForm.estimatedHours}" />
                            <c:if test="${not empty workPackageBinding and workPackageBinding.hasFieldErrors('estimatedHours')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${workPackageBinding.getFieldErrors('estimatedHours')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>
                        Create Work Package
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<c:if test="${showCreateWorkPackageModal}">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modalElement = document.getElementById('${workPackageModalId}');
            if (!modalElement || !window.bootstrap || !bootstrap.Modal) return;
            bootstrap.Modal.getOrCreateInstance(modalElement).show();
        });
    </script>
</c:if>
