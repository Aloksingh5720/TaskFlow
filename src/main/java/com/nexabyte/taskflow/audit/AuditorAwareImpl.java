package com.nexabyte.taskflow.audit;

import java.util.Optional;

import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.nexabyte.taskflow.entities.User;

@Component("auditAwareImpl")
public class AuditorAwareImpl implements AuditorAware<Long> {

    private static final long SYSTEM_USER_ID = 0L;

    @Override
    public Optional<Long> getCurrentAuditor() {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null ||
                !authentication.isAuthenticated() ||
                authentication.getPrincipal().equals("anonymousUser")) {

            return Optional.of(SYSTEM_USER_ID);
        }

        Object principal = authentication.getPrincipal();

        if (principal instanceof User user) {
            return Optional.ofNullable(user.getId());
        }

        return Optional.empty();
    }
}