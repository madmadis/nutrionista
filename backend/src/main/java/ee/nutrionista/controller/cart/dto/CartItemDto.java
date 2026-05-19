package ee.nutrionista.controller.cart.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItemDto {
    private Integer cartItemId;
    private Integer nutrientId;
    private String nutrientName;
    private BigDecimal nutrientPrice;
    private Integer quantity;
}
