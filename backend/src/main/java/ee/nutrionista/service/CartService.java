package ee.nutrionista.service;

import ee.nutrionista.controller.cart.dto.CartDto;
import ee.nutrionista.infrastructure.exception.CartNotFoundException;
import ee.nutrionista.persistence.cart.Cart;
import ee.nutrionista.persistence.cart.CartMapper;
import ee.nutrionista.persistence.cart.CartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CartService {

    private final CartRepository cartRepository;
    private final CartMapper cartMapper;

    public CartDto findCartByUserId(Integer userId) {
        Cart cart = cartRepository.findCartByUserId(userId).orElseThrow(CartNotFoundException::new);
        return cartMapper.toCartDto(cart);
    }
}


