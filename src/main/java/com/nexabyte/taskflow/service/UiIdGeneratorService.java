package com.nexabyte.taskflow.service;

public interface UiIdGeneratorService {

    String generateProjectUiId(Long id);

    String generateMemberUiId(Long id);

    String generateWorkPackageUiId(Long id);
}
