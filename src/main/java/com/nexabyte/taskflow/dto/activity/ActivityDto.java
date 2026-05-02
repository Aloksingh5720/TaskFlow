package com.nexabyte.taskflow.dto.activity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActivityDto {

    private static final DateTimeFormatter DASHBOARD_DATE_FORMAT = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm");

    private Long id;

    private String description;

    private String actor;

    private LocalDateTime createdAt;

    public String getType() {
        if (description == null)
            return "GENERAL";
        String normalizedDescription = description.toLowerCase(Locale.ROOT);
        if (normalizedDescription.contains("create"))
            return "CREATE";
        if (normalizedDescription.contains("added"))
            return "CREATE";
        if (normalizedDescription.contains("scheduled"))
            return "CREATE";
        if (normalizedDescription.contains("update"))
            return "UPDATE";
        if (normalizedDescription.contains("delete"))
            return "DELETE";
        if (normalizedDescription.contains("removed"))
            return "DELETE";
        if (normalizedDescription.contains("status"))
            return "STATUS";

        return "GENERAL";
    }

    public String getDisplayActor() {
        if (actor != null && !actor.isBlank()) {
            return actor;
        }
        return "System";
    }

    public String getActorInitial() {
        String displayActor = getDisplayActor();
        if (!displayActor.isEmpty()) {
            return displayActor.substring(0, 1).toUpperCase(Locale.ROOT);
        }
        return "?";
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) {
            return null;
        }
        return createdAt.format(DASHBOARD_DATE_FORMAT);
    }
}
