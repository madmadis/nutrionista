package ee.nutrionista.controller.cart;

import ee.nutrionista.controller.cart.dto.CartDto;
import ee.nutrionista.service.CartService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class CartController {
    private final CartService cartService;

    @GetMapping("/users/{userId}/cart")
    @Operation(summary = "Näita kasutaja ostukorvi")
    public CartDto findCartByUserId(@PathVariable Integer userId) {
        return cartService.findCartByUserId(userId);
    }

}
