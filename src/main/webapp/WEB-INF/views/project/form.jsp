<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="page-header mb-4">
    <h2 class="mb-1">${project.id == null ? 'Create Project' : 'Edit Project'}</h2>
    <p class="text-muted mb-0">Define project scope, hierarchy, and visibility settings.</p>
</div>

<div class="card" style="max-width:680px">
    <div class="card-body">
    <c:url var="formAction"
        value="${pageContext.request.contextPath}/projects${project.id != null ? '/' : ''}${project.id != null ? project.id : ''}" />
    <form:form method="post" modelAttribute="project" action="${formAction}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <form:hidden path="id" />

        <div class="mb-4">
            <form:label path="name" class="form-label">Project Name</form:label>
            <form:input path="name" class="form-control" required="true" placeholder="Enter project name" />
            <form:errors path="name" cssClass="text-danger" />
        </div>

        <div class="mb-4">
            <form:label path="description" class="form-label">Description</form:label>
            <form:textarea path="description" class="form-control" rows="4" required="true"
                placeholder="Brief description of this project" />
            <form:errors path="description" cssClass="text-danger" />
        </div>

        <div class="mb-4">
            <form:label path="parentId" class="form-label">Parent Project</form:label>
            <form:select path="parentId" class="form-select">
                <form:option value="" label="None (Top-Level)" />
                <c:forEach items="${projects}" var="p">
                    <c:if test="${project.id == null || project.id != p.id}">
                        <form:option value="${p.id}">${p.name}</form:option>
                    </c:if>
                </c:forEach>
            </form:select>
        </div>

        <c:choose>
            <c:when test="${project.id == null}">
                <div class="mb-4">
                    <label class="form-label">Project Status</label>
                    <div>
                        <span class="badge rounded-pill text-bg-secondary">NOT STARTED (Default)</span>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mb-4">
                    <form:label path="projectStatus" class="form-label">Project Status *</form:label>
                    <form:select path="projectStatus" class="form-select" required="true">
                        <form:option value="" label="-- Select Status --" />
                        <c:forEach items="${projectStatuses}" var="status">
                            <form:option value="${status.name()}">${fn:replace(status.name(), '_', ' ')}</form:option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="projectStatus" cssClass="text-danger" />
                </div>
            </c:otherwise>
        </c:choose>

        <div class="d-flex flex-wrap gap-2">
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-check-lg me-1"></i>${project.id == null ? 'Create Project' : 'Save Changes'}
            </button>
            <a href="${pageContext.request.contextPath}/projects" class="btn btn-secondary">
                <i class="bi bi-x-lg me-1"></i>Cancel
            </a>
        </div>
    </form:form>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
