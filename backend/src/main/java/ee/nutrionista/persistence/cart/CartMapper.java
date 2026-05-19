package ee.nutrionista.persistence.cart;

import ee.nutrionista.controller.cart.dto.CartDto;
import ee.nutrionista.controller.cart.dto.CartItemDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CartMapper {

    @Mapping(source = "id", target = "cartId")
    @Mapping(source = "user.id", target = "userId")
    @Mapping(source = "items", target = "items")
    CartDto toCartDto(Cart cart);

    @Mapping(source = "id", target = "cartItemId")
    @Mapping(source = "nutrient.id", target = "nutrientId")
    @Mapping(source = "nutrient.name", target = "nutrientName")
    @Mapping(source = "nutrient.price", target = "nutrientPrice")
    @Mapping(source = "quantity", target = "quantity")
    CartItemDto toCartItemDto(CartItem cartItem);

    List<CartItemDto> toCartItemDtos(List<CartItem> cartItems);

}