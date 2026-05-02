<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="editMeetingBinding" value="${requestScope['org.springframework.validation.BindingResult.editMeeting']}" />

<div class="modal fade" id="editMeetingModal" tabindex="-1" aria-labelledby="editMeetingModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2 meeting-modal meeting-modal-compact">
            <form id="editMeetingForm" method="post" action="${pageContext.request.contextPath}/meetings/${editMeeting.id}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" name="id" id="editMeetingId" value="${editMeeting.id}" />
                <input type="hidden" name="projectId" id="editMeetingProjectId" value="${editMeeting.projectId}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="editMeetingModalLabel">Edit Meeting</h5>
                        <p class="mb-0 text-muted small">Update the schedule, attendees, and agenda.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-2 meeting-form-grid">
                        <div class="col-md-8">
                            <label for="editMeetingProjectName" class="form-label">Project</label>
                            <input id="editMeetingProjectName" type="text" class="form-control" readonly />
                        </div>

                        <div class="col-md-4">
                            <label for="editMeetingTitle" class="form-label">Title *</label>
                            <input id="editMeetingTitle" name="title"
                                class="form-control ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('title') ? 'is-invalid' : ''}"
                                required="true" placeholder="Sprint planning, client sync, design review..."
                                value="${editMeeting.title}" />
                            <c:if test="${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('title')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${editMeetingBinding.getFieldErrors('title')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-8">
                            <label for="editMeetingStatus" class="form-label">Status *</label>
                            <select id="editMeetingStatus" name="meetingStatus"
                                class="form-select ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('meetingStatus') ? 'is-invalid' : ''}">
                                <c:forEach items="${meetingStatuses}" var="status">
                                    <option value="${status.name()}" ${editMeeting.meetingStatus == status ? 'selected' : ''}>
                                        ${fn:replace(status.name(), '_', ' ')}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-12">
                            <label for="editMeetingLink" class="form-label">Meeting Link</label>
                            <input id="editMeetingLink" name="meetingLink" type="url"
                                class="form-control ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('meetingLink') ? 'is-invalid' : ''}"
                                placeholder="https://meet.google.com/..." value="${editMeeting.meetingLink}" />
                            <c:if test="${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('meetingLink')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${editMeetingBinding.getFieldErrors('meetingLink')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="form-text">Participants will be able to join directly from this link.</div>
                        </div>

                        <div class="col-md-4">
                            <label for="editMeetingDate" class="form-label">Meeting Date *</label>
                            <input id="editMeetingDate" name="date" type="date"
                                class="form-control ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('date') ? 'is-invalid' : ''}"
                                value="${editMeeting.date}" />
                            <c:if test="${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('date')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${editMeetingBinding.getFieldErrors('date')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="editMeetingStartTime" class="form-label">Start Time *</label>
                            <input id="editMeetingStartTime" name="starTime" type="time"
                                class="form-control ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('starTime') ? 'is-invalid' : ''}"
                                value="${editMeeting.starTime}" />
                            <c:if test="${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('starTime')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${editMeetingBinding.getFieldErrors('starTime')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-md-4">
                            <label for="editMeetingDuration" class="form-label">Duration (hours) *</label>
                            <input id="editMeetingDuration" name="duration" type="number" min="0.25" step="0.25"
                                class="form-control ${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('duration') ? 'is-invalid' : ''}"
                                placeholder="1.00" value="${editMeeting.duration}" />
                            <c:if test="${not empty editMeetingBinding and editMeetingBinding.hasFieldErrors('duration')}">
                                <div class="invalid-feedback">
                                    <c:forEach items="${editMeetingBinding.getFieldErrors('duration')}" var="error">
                                        <div>${error.defaultMessage}</div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="col-12">
                            <div class="d-flex align-items-center justify-content-between mb-1">
                                <label class="form-label mb-0">Participants</label>
                                <label class="d-flex align-items-center gap-1 mb-0" style="font-size: 0.8rem; cursor: pointer;">
                                    <input type="checkbox" id="editMeetingParticipantsSelectAll"
                                        class="form-check-input meeting-participant-checkbox mt-0" />
                                    <span class="text-muted">Select all</span>
                                </label>
                            </div>
                            <div id="editMeetingParticipants"
                                style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1px 4px; max-height: 110px; overflow-y: auto; padding: 5px 8px; border: 1px solid var(--bs-border-color); border-radius: 6px;">
                                <c:forEach items="${projectMembers}" var="member">
                                    <c:if test="${member.userId != currentUserId}">
                                        <label class="d-flex align-items-center gap-2 py-1 px-1 rounded"
                                            style="font-size: 0.8rem; cursor: pointer; min-width: 0;">
                                            <input type="checkbox" name="participantIds" value="${member.userId}"
                                                class="form-check-input meeting-participant-checkbox flex-shrink-0 mt-0"
                                                ${not empty editMeeting.participantIds and editMeeting.participantIds.contains(member.userId) ? 'checked' : ''} />
                                            <span class="text-truncate">
                                                ${member.username}
                                                <span class="text-muted">(${member.role})</span>
                                            </span>
                                        </label>
                                    </c:if>
                                </c:forEach>
                            </div>
                            <div class="form-text">Project members only. You remain part of the meeting automatically.</div>
                        </div>

                        <div class="col-12">
                            <label for="editMeetingDescription" class="form-label">Agenda / Notes</label>
                            <textarea id="editMeetingDescription" name="description" class="form-control" rows="3"
                                placeholder="Add agenda points, meeting link, preparation notes, or context.">${editMeeting.description}</textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        var editMeetingModal = document.getElementById('editMeetingModal');
        if (!editMeetingModal) return;

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

        function parseParticipantIds(rawValue) {
            if (!rawValue) return [];
            return rawValue
                .replace('[', '')
                .replace(']', '')
                .split(',')
                .map(function (value) { return value.trim(); })
                .filter(function (value) { return value.length > 0; });
        }

        function populateParticipants(projectId, selectedParticipantIds) {
            var participantsContainer = editMeetingModal.querySelector('#editMeetingParticipants');
            var selectAll = editMeetingModal.querySelector('#editMeetingParticipantsSelectAll');
            if (!participantsContainer) return;

            var members = projectMembersByProject[projectId] || [];
            participantsContainer.innerHTML = '';
            if (selectAll) selectAll.checked = false;

            if (members.length === 0) {
                participantsContainer.innerHTML = '<div class="text-muted px-1 py-2" style="font-size:0.8rem; grid-column: 1 / -1;">No additional project members available.</div>';
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
                checkbox.checked = selectedParticipantIds.indexOf(member.id) !== -1;

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

        editMeetingModal.addEventListener('show.bs.modal', function (event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;

            var meetingId = trigger.getAttribute('data-edit-id') || '';
            var projectId = trigger.getAttribute('data-edit-project-id') || '';
            var form = editMeetingModal.querySelector('#editMeetingForm');
            if (form) {
                form.setAttribute('action', '${pageContext.request.contextPath}/meetings/' + meetingId);
            }

            var idInput = editMeetingModal.querySelector('#editMeetingId');
            if (idInput) idInput.value = meetingId;

            var projectIdInput = editMeetingModal.querySelector('#editMeetingProjectId');
            if (projectIdInput) projectIdInput.value = projectId;

            var projectNameInput = editMeetingModal.querySelector('#editMeetingProjectName');
            if (projectNameInput) projectNameInput.value = trigger.getAttribute('data-edit-project-name') || '';

            var titleInput = editMeetingModal.querySelector('#editMeetingTitle');
            if (titleInput) titleInput.value = trigger.getAttribute('data-edit-title') || '';

            var statusInput = editMeetingModal.querySelector('#editMeetingStatus');
            if (statusInput) statusInput.value = trigger.getAttribute('data-edit-status') || 'SCHEDULED';

            var dateInput = editMeetingModal.querySelector('#editMeetingDate');
            if (dateInput) dateInput.value = trigger.getAttribute('data-edit-date') || '';

            var timeInput = editMeetingModal.querySelector('#editMeetingStartTime');
            if (timeInput) timeInput.value = trigger.getAttribute('data-edit-start-time') || '';

            var durationInput = editMeetingModal.querySelector('#editMeetingDuration');
            if (durationInput) durationInput.value = trigger.getAttribute('data-edit-duration') || '';

            var descriptionInput = editMeetingModal.querySelector('#editMeetingDescription');
            if (descriptionInput) descriptionInput.value = trigger.getAttribute('data-edit-description') || '';

            var meetingLinkInput = editMeetingModal.querySelector('#editMeetingLink');
            if (meetingLinkInput) meetingLinkInput.value = trigger.getAttribute('data-edit-link') || '';

            var selectedParticipantIds = parseParticipantIds(trigger.getAttribute('data-edit-participant-ids'));
            populateParticipants(projectId, selectedParticipantIds);
        });

        var selectAll = editMeetingModal.querySelector('#editMeetingParticipantsSelectAll');
        var participantsContainer = editMeetingModal.querySelector('#editMeetingParticipants');

        if (selectAll && participantsContainer) {
            selectAll.addEventListener('change', function () {
                participantsContainer.querySelectorAll('input[name="participantIds"]').forEach(function (checkbox) {
                    checkbox.checked = selectAll.checked;
                });
            });

            participantsContainer.addEventListener('change', function (event) {
                if (event.target.name !== 'participantIds') return;
                var checkboxes = participantsContainer.querySelectorAll('input[name="participantIds"]');
                selectAll.checked = checkboxes.length > 0 && Array.from(checkboxes).every(function (checkbox) {
                    return checkbox.checked;
                });
            });
        }
    })();
</script>

<c:if test="${showEditMeetingModal}">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modalElement = document.getElementById('editMeetingModal');
            if (!modalElement) return;
            bootstrap.Modal.getOrCreateInstance(modalElement).show();
        });
    </script>
</c:if>