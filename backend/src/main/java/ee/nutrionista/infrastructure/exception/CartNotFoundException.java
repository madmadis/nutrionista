package ee.nutrionista.infrastructure.exception;

import ee.nutrionista.infrastructure.error.ErrorResponse;
import lombok.Getter;

@Getter
public class CartNotFoundException extends RuntimeException{
    private final String message;
    private final Integer errorCode;

    public CartNotFoundException() {
        super(ErrorResponse.CART_NOT_FOUND.getMessage());
        this.message = ErrorResponse.CART_NOT_FOUND.getMessage();
        this.errorCode = ErrorResponse.CART_NOT_FOUND.getErrorCode();
    }
}
