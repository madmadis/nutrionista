package ee.nutrionista.infrastructure.exception;

import ee.nutrionista.infrastructure.error.ErrorResponse;
import lombok.Getter;

@Getter
public class NutrientNotFoundException extends RuntimeException {
    private final String message;
    private final Integer errorCode;

    public NutrientNotFoundException() {
        super(ErrorResponse.NUTRIENT_NOT_FOUND.getMessage());
        this.message = ErrorResponse.NUTRIENT_NOT_FOUND.getMessage();
        this.errorCode = ErrorResponse.NUTRIENT_NOT_FOUND.getErrorCode();
    }
}

