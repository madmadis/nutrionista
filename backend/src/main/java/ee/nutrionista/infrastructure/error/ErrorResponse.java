package ee.nutrionista.infrastructure.error;

import lombok.Getter;

@Getter
public enum ErrorResponse {
    INCORRECT_CREDENTIALS("Vale email või parool", 401),
    NUTRIENT_NOT_FOUND("Toodet ei leitud", 404),
    ;

    private final String message;
    private final Integer errorCode;

    ErrorResponse(String message, Integer errorCode) {
        this.message = message;
        this.errorCode = errorCode;
    }
}
