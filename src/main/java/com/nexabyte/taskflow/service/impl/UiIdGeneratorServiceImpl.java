package com.nexabyte.taskflow.service.impl;

import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.service.UiIdGeneratorService;

@Service
public class UiIdGeneratorServiceImpl implements UiIdGeneratorService {

    private static final int NUMERIC_WIDTH = 6;

    @Override
    public String generateProjectUiId(Long id) {
        return format("PR", id);
    }

    @Override
    public String generateMemberUiId(Long id) {
        return format("MM", id);
    }

    @Override
    public String generateWorkPackageUiId(Long id) {
        return format("WP", id);
    }

    private String format(String prefix, Long id) {
        if (id == null) {
            throw new IllegalArgumentException("UI ID cannot be generated without a database ID");
        }

        return prefix + "-" + String.format("%0" + NUMERIC_WIDTH + "d", id);
    }
}
