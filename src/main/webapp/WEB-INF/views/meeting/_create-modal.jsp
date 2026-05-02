<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="meetingBinding" value="${requestScope['org.springframework.validation.BindingResult.meeting']}" />

<div class="modal fade" id="createMeetingModal" tabindex="-1" aria-labelledby="createMeetingModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2 meeting-modal meeting-modal-compact">
            <form method="post" action="${pageContext.request.contextPath}/meetings">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="createMeetingModalLabel">Schedule Meeting</h5>
                        <p class="mb-0 text-muted small">Choose a project first, then assign the meeting participants.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-2 meeting-form-grid">
                        <div class="col-12">
                            <label for="meetingProjectId" class="form-label">Project *</label>
                            <select id="meetingProjectId" name="projectId"
                                class="form-select ${not empty meetingBinding and meetingBinding.hasFieldErrors('projectId') ? 'is-invalid' : ''}"
                                required="true">
                                <option value="">Select project</option>
                                <c:forEach items="${availableProjects}" var="projectOption">
                                    <option value="${projectOption.id}" ${meeting.projectId == projectOption.id ? 'selected' : ''}>
                                        ${projectOption.name}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('projectId')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('projectId')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-8">
                            <label for="meetingTitle" class="form-label">Title *</label>
                            <input id="meetingTitle" name="title"
                                class="form-control ${not empty meetingBinding and meetingBinding.hasFieldErrors('title') ? 'is-invalid' : ''}"
                                required="true" placeholder="Sprint planning, client sync, design review..."
                                value="${meeting.title}" />
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('title')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('title')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="meetingStatus" class="form-label">Status *</label>
                            <select id="meetingStatus" name="meetingStatus"
                                class="form-select ${not empty meetingBinding and meetingBinding.hasFieldErrors('meetingStatus') ? 'is-invalid' : ''}">
                                <c:forEach items="${meetingStatuses}" var="status">
                                    <option value="${status.name()}" ${meeting.meetingStatus == status ? 'selected' : ''}>
                                        ${fn:replace(status.name(), '_', ' ')}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-12">
                            <label for="meetingLink" class="form-label">Meeting Link</label>
                            <input id="meetingLink" name="meetingLink" type="url"
                                class="form-control ${not empty meetingBinding and meetingBinding.hasFieldErrors('meetingLink') ? 'is-invalid' : ''}"
                                placeholder="https://meet.google.com/..." value="${meeting.meetingLink}" />
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('meetingLink')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('meetingLink')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="form-text">Paste a join URL so participants can open the meeting directly.</div>
                        </div>

                        <div class="col-md-4">
                            <label for="meetingDate" class="form-label">Meeting Date *</label>
                            <input id="meetingDate" name="date" type="date"
                                class="form-control ${not empty meetingBinding and meetingBinding.hasFieldErrors('date') ? 'is-invalid' : ''}"
                                value="${meeting.date}" />
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('date')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('date')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="meetingStartTime" class="form-label">Start Time *</label>
                            <input id="meetingStartTime" name="starTime" type="time"
                                class="form-control ${not empty meetingBinding and meetingBinding.hasFieldErrors('starTime') ? 'is-invalid' : ''}"
                                value="${meeting.starTime}" />
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('starTime')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('starTime')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="meetingDuration" class="form-label">Duration (hours) *</label>
                            <input id="meetingDuration" name="duration" type="number" min="0.25" step="0.25"
                                class="form-control ${not empty meetingBinding and meetingBinding.hasFieldErrors('duration') ? 'is-invalid' : ''}"
                                placeholder="1.00" value="${meeting.duration}" />
                            <c:if test="${not empty meetingBinding and meetingBinding.hasFieldErrors('duration')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${meetingBinding.getFieldErrors('duration')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-12">
                            <div class="d-flex align-items-center justify-content-between mb-1">
                                <label class="form-label mb-0">Participants</label>
                                <label class="d-flex align-items-center gap-1 mb-0" style="font-size: 0.8rem; cursor: pointer;">
                                    <input type="checkbox" id="meetingParticipantsSelectAll"
                                        class="form-check-input meeting-participant-checkbox mt-0" />
                                    <span class="text-muted">Select all</span>
                                </label>
                            </div>
                            <div id="meetingParticipants"
                                style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1px 4px; max-height: 110px; overflow-y: auto; padding: 5px 8px; border: 1px solid var(--bs-border-color); border-radius: 6px;">
                            </div>
                            <div class="form-text">Project members only. You are added to the meeting automatically.</div>
                        </div>

                        <div class="col-12">
                            <label for="meetingDescription" class="form-label">Agenda / Notes</label>
                            <textarea id="meetingDescription" name="description" class="form-control" rows="3"
                                placeholder="Add agenda points, meeting link, preparation notes, or context.">${meeting.description}</textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-calendar-plus me-1"></i>Schedule Meeting
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        var projectMembersByProject = {
            <c:forEach items="${availableProjects}" var="projectOption" varStatus="projectStatus">
                "${projectOption.id}": [
                    <c:forEach items="${projectMembersByProject[projectOption.id]}" var="member" varStatus="memberStatus">
                        <c:if test="${member.userId != currentUserId}">
                            {
                                id: "${member.userId}",
                                label: "${fn:escapeXml(member.username)} (${fn:escapeXml(member.role)})"
                            }<c:if test="${!memberStatus.last}">,</c:if>
                        </c:if>
                    </c:forEach>
                ]<c:if test="${!projectStatus.last}">,</c:if>
            </c:forEach>
        };

        function parseSelectedIds(rawValue) {
            if (!rawValue) return [];
            return rawValue
                .replace('[', '')
                .replace(']', '')
                .split(',')
                .map(function (value) { return value.trim(); })
                .filter(function (value) { return value.length > 0; });
        }

        function populateParticipants(projectSelectId, participantsContainerId, selectedIds) {
            var projectSelect = document.getElementById(projectSelectId);
            var participantsContainer = document.getElementById(participantsContainerId);
            var selectAll = document.getElementById('meetingParticipantsSelectAll');
            if (!projectSelect || !participantsContainer) return;

            var projectId = projectSelect.value;
            var members = projectMembersByProject[projectId] || [];
            participantsContainer.innerHTML = '';
            if (selectAll) selectAll.checked = false;

            if (members.length === 0) {
                participantsContainer.innerHTML = '<div class="text-muted px-1 py-2" style="font-size:0.8rem; grid-column: 1 / -1;">Select a project to choose participants.</div>';
                return;
            }

            members.forEach(function (member) {
                var wrapper = document.createElement('label');
                wrapper.className = 'd-flex align-items-center gap-2 py-1 px-1 rounded';
                wrapper.style.cssText = 'font-size: 0.8rem; cursor: pointer; min-width: 0;';

                var checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.name = 'participantIds';
                checkbox.value = member.id;
                checkbox.className = 'form-check-input meeting-participant-checkbox flex-shrink-0 mt-0';
                checkbox.checked = selectedIds.indexOf(member.id) !== -1;

                var text = document.createElement('span');
                text.className = 'text-truncate';
                text.textContent = member.label;

                wrapper.appendChild(checkbox);
                wrapper.appendChild(text);
                participantsContainer.appendChild(wrapper);
            });

            if (selectAll) {
                var checkboxes = participantsContainer.querySelectorAll('input[name="participantIds"]');
                selectAll.checked = checkboxes.length > 0 && Array.from(checkboxes).every(function (checkbox) {
                    return checkbox.checked;
                });
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var projectSelect = document.getElementById('meetingProjectId');
            var participantsSelect = document.getElementById('meetingParticipants');
            var selectAll = document.getElementById('meetingParticipantsSelectAll');
            if (!projectSelect || !participantsSelect) return;

            var selectedIds = parseSelectedIds("${meeting.participantIds}");
            populateParticipants('meetingProjectId', 'meetingParticipants', selectedIds);
            projectSelect.addEventListener('change', function () {
                populateParticipants('meetingProjectId', 'meetingParticipants', []);
            });

            if (selectAll) {
                selectAll.addEventListener('change', function () {
                    participantsSelect.querySelectorAll('input[name="participantIds"]').forEach(function (checkbox) {
                        checkbox.checked = selectAll.checked;
                    });
                });
            }

            participantsSelect.addEventListener('change', function (event) {
                if (!selectAll || event.target.name !== 'participantIds') return;
                var checkboxes = participantsSelect.querySelectorAll('input[name="participantIds"]');
                selectAll.checked = checkboxes.length > 0 && Array.from(checkboxes).every(function (checkbox) {
                    return checkbox.checked;
                });
            });
        });
    })();
</script>

<c:if test="${showCreateMeetingModal}">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modalElement = document.getElementById('createMeetingModal');
            if (!modalElement) return;
            bootstrap.Modal.getOrCreateInstance(modalElement).show();
        });
    </script>
</c:if>